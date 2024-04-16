//
//  LECSComponentChart.swift
//
//
//  Created by David Kanenwisher on 3/19/24.
//

import Foundation

/// Stores Components grouped into Archetypes as rows.
protocol LECSComponentChart {
    /// Creates a row in the ComponentChart.
    func createRow() -> LECSRowId

    /// Reads Component of the type from the given row.
    /// TODO: do these need to be generic?
    func readComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type)

    /// Deletes the row.
    func delete(row rowId: LECSRowId)

    /// Checks to see if a LECSRowId has a component
    func component(in row: LECSRowId, type: LECSComponent.Type) -> Bool

    /// Adds the LECSCCComponent to the row.
    /// This makes the provided LECSCCRowId stale, so the caller needs to use the return LECSCCRowId.
    func addComponentTo(row rowId: LECSRowId, component: LECSComponent) -> LECSRowId

    /// Removes the LECSCCComponent from the row.
    /// This makes the provided LECSCCRowId stale, so the caller needs to use the return LECSRowId.
    /// TODO: do these need to be generic?
    func removeComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) -> LECSRowId

    /// Read all rows that have the Components in the query.
    /// For now, need to use LECSCCColumns to read from LECSCCRowId in the order of LECSQuery: LECSRow[LECSCColumns[0].col]
    func select(_ query: LECSQuery, block: (LECSRow, LECSColumns) -> Void)

    /// Allows updates of the LECSRows selected by the LECSQuery.
    /// The block should return the modified LECSRow to be stored in the ComponentChart.
    func update(_ query: LECSQuery, block: (LECSRow, LECSColumns) -> LECSRow)

    func update(_ componentIds: [LECSComponentId], block: (LECSRow, LECSColumns) -> LECSRow)

    func convertToComponentIds(_ query: LECSQuery) -> [LECSComponentId]
}

/// A LECSFixedComponentChart is a ComponentChart that has a fixed size.
class LECSFixedComponentChart {

    private let root: LECSArchetype

    private let factory: LECSArchetypeFactory

    private var archetypes: [LECSArchetype] = []

    private var components: [MetatypeWrapper:LECSComponentId] = [:]

    private var queryCache: [String:[LECSArchetype]] = [:]

    // TODO: rename componentIdArchetype?
    private var componentArchetype: [LECSComponentId:[LECSArchetypeId:LECSArchetypeColumn]] = [:]

    init(factory: LECSArchetypeFactory = LECSArchetypeFactory(size: 1000)) {
        self.factory = factory
        root = factory.create(id: LECSArchetypeId(0), type: [], components: [])
        archetypes.append(root)
    }

    func createRow() -> LECSRowId {
        return root.createRow()
    }

    func readComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) -> T {
        archetypes[rowId.archetypeId.rawValue].read(rowId)[componentArchetype[components[type]!]![rowId.archetypeId]!.col] as! T
    }

    func delete(row rowId: LECSRowId) {
        // TODO: don't really like this rawValue
        archetypes[rowId.archetypeId.rawValue].delete(rowId)
    }

    func component(in row: LECSRowId, type: LECSComponent.Type) -> Bool {
        guard let componentId = components[type] else {
            fatalError("The type:[\(type)] hasn't been added yet. Do you need to adjust your code to add it?")
        }

        return componentArchetype[componentId]?[row.archetypeId] != nil
    }

    func addComponentTo(row rowId: LECSRowId, component: LECSComponent) -> LECSRowId {
        // 1. Get the ComponentId
        // 2. Get the Archetype.
        // 3. If it's already in the Archetype update the Component.
        // 4. Follow the add edge to the destination Archetype.
        //  4a. If the add edge exists follow it to the Archetype.
        //  4b. If the add edge is null create a new Archetype.
        // 5. Cut the Row from the current Archetype and add it to the new Archetype with the additional Component.
        // 6. Create a new Row with the new Archetype.
        // 7. Return the Row.
        let componentId = componentId(component)
        let archetype = archetypes[rowId.archetypeId.rawValue]

        if let column = column(componentId: componentId, archetypeId: archetype.id) {
            return archetype.update(rowId: rowId, column: column, component: component)
        } else {
            return updateNearestArchetype(archetype: archetype, rowId: rowId, componentId: componentId, component: component)
        }
    }

    func removeComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) -> LECSRowId {
        // 1. Explode if the component or archetype doesn't exist.
        // 2. Get the Archetype
        // 3. Follow the remove edge to the destination Archetype.
        //    2a. If the remove edge exists follow it to the Archetype.
        //    3b. If the remove edge is null create a new Archetype.
        // 4. Cut the row from the current Archetype and remove it from the destination Archetype without the component.
        // 5. Create a new Row with the destination Archetype.
        // 6. Return the Row.
        guard let componentId = components[type] else {
            fatalError("A component for type \(type) doesn't exist. Did you remove it before adding it to something?")
        }

        let archetype = archetypes[rowId.archetypeId.rawValue]
        guard let column = column(componentId: componentId, archetypeId: archetype.id) else {
            fatalError("The component[\(componentId) for type \(type) does not have a column in archetype[\(archetype.id)].")
        }

        //TODO: If a remove edge exists this work can be skipped, right?
        //TODO: is there a way to clean this up?
        var row = archetype.delete(rowId)
        row.remove(at: column.col)
        var type = archetype.type
        type.remove(at: column.col)
        var components = archetype.componentTypes
        components.remove(at: column.col)

        return findOrCreateArchetype(
            archetype: archetype,
            componentId: componentId,
            row: row,
            type: type,
            components: components
        )
    }

    func select(_ query: LECSQuery, block: (LECSRow, LECSColumns) -> Void) {
        self.query(queryComponentIds: convertTypesToComponentIds(query: query), readOnly: true) { components, columns in
            block(components, columns)
            return []
        }
    }

    func update(_ query: LECSQuery, block: (LECSRow, LECSColumns) -> LECSRow) {
        self.query(queryComponentIds: convertTypesToComponentIds(query: query), readOnly: false, block: block)
    }

    func update(_ componentIds: [LECSComponentId], block: (LECSRow, LECSColumns) -> LECSRow) {
        self.query(queryComponentIds: componentIds, readOnly: false, block: block)
    }

    func convertQueryToComponentIds(_ query: LECSQuery) -> [LECSComponentId] {
        convertTypesToComponentIds(query: query)
    }

    private func query(queryComponentIds: [LECSComponentId], readOnly: Bool, block: (LECSRow, LECSColumns) -> LECSRow) {
        //TODO: find a way with a low start-up time way(or one that can be prepared ahead of time) to spread archetype queries across a thread pool.
        // Only sort when selecting, otherwise the original order needs to maintained to ensure they can be mapped to columns correctly.
        selectArchetypes(queryComponentIds: sortedComponentIds(queryComponentIds)).forEach { archetype in
            let columns:[LECSArchetypeColumn] = queryComponentIds.map { componentArchetype[$0]![archetype.id]! }

            // Using indexes appears to be ~30% faster than using iterators.
            // It seems way better then to keep using direct access over using an iterator.
            (0..<archetype.largestIndex).forEach { index in
                if archetype.rowExists(at: index) {



                    let changeSet: LECSRow = block(archetype.readRow(at: index), columns)
                    var idx = 0
                    if !readOnly {
                        columns.forEach {
                            archetype.update(
                                index: index,
                                column: $0,
                                component: changeSet[idx]
                            )
                            idx += 1
                        }
                    }
                }
            }
        }
    }

    private func sortedComponentIds(_ componentIds: [LECSComponentId]) -> [LECSComponentId] {
        componentIds.sorted(by: { $0.id < $1.id })
    }

    private func convertTypesToComponentIds(query: LECSQuery) -> [LECSComponentId] {
        query.map { components[$0]! }
    }

    private func selectArchetypes(queryComponentIds: [LECSComponentId]) -> [LECSArchetype] {
        guard let firstComponentId = queryComponentIds.first else {
            return []
        }

        let queryHash = queryHash(queryComponentIds)

        if let selectedArchetypes = queryCache[queryHash] {
            return selectedArchetypes
        }

        let selectedArchetypes: [LECSArchetype] = componentArchetype[firstComponentId]?.map { archetypeRecord in
            let archetype = archetypes[archetypeRecord.key.rawValue]

            if queryComponentIds.allSatisfy({ archetype.type.contains($0) }) {
                return archetype
            } else {
                return nil
            }

        }.compactMap { $0 } ?? []

        // update the cache
        queryCache[queryHash] = selectedArchetypes

        return selectedArchetypes
    }

    private func updateNearestArchetype(
        archetype: LECSArchetype,
        rowId: LECSRowId,
        componentId: LECSComponentId,
        component: LECSComponent
    ) -> LECSRowId {
        let row = archetype.delete(rowId)
        let typeComponents = (archetype.type + [componentId]).aligned(with: (row + [component]))

        return findOrCreateArchetype(
            archetype: archetype,
            componentId: componentId,
            row: typeComponents.row(),
            type: typeComponents.type(),
            components: archetype.componentTypes + [type(of: component)]
        )
    }

    private func findOrCreateArchetype(
        archetype: LECSArchetype,
        componentId: LECSComponentId,
        row: LECSRow,
        type: [LECSComponentId],
        components: [LECSComponent.Type]
    ) -> LECSRowId {
        if let nextArchetypeId = archetype.edges[componentId] {
            return archetypes[nextArchetypeId.rawValue].insert(row: row)
        } else {
            let nextArchetype = nearestNeighborWithType(type: type, components: components)
            return nextArchetype.insert(row: row)
        }
    }

    private func nearestNeighborWithType(type: [LECSComponentId], components: [LECSComponent.Type]) -> LECSArchetype {
        var nextArchetype = root
        //TODO: is it faster to use forEach with a counter or to use for in?
        for i in type.indices {
            let componentId = type[i]

            if let next = nextArchetype.edges[componentId] {
                nextArchetype = archetypes[next.rawValue]
            } else {
                nextArchetype = createArchetypeForType(
                    previousArchetype: nextArchetype,
                    type: Array(type.prefix(upTo: i + 1)),
                    components: Array(components.prefix(upTo: i + 1))
                )
            }
        }

        return nextArchetype
    }

    private func createArchetypeForType(
        previousArchetype: LECSArchetype,
        type: [LECSComponentId],
        components: [LECSComponent.Type]
    ) -> LECSArchetype {
        // Potential critical region because it takes many steps to create an LECSArchetype.

        // Create the archetype and add it to the list of archetypes
        let archetypeId = LECSArchetypeId(archetypes.count)
        let newArchetype = createArchetype(id: archetypeId, type: type, components: components)
        archetypes.append(newArchetype)

        // Connect the edges.
        // Keeping things ordered.
        // The previous archetype uses the last element in the type go to the new archetype.
        // The new archetype uses the last element in the type to go to the previous archetype.
        // This way adding the component to the previous archetype brings you to the new archetype.
        // Removing the component from the new archetype takes you back to the previous archetype.
        previousArchetype.edges[type.last!] = newArchetype.id
        newArchetype.edges[type.last!] = previousArchetype.id

        // Update the component to archetype index making it possible to determine what archetypes have component.
        for column in type.indices {
            let componentId = type[column]

            // Need to make sure a component can have many archetypes,
            // so ensure a dictionary exists before adding another archetype.
            componentArchetype[componentId, default: [:]][archetypeId] = LECSArchetypeColumn(col: column)
        }

        return newArchetype
    }

    private func componentId(_ component: LECSComponent) -> LECSComponentId {
        if let id = components[type(of: component)] { // might have to cast to Any, see type(of:) help
            return id
        } else {
            return createComponent(component)
        }
    }

    private func createComponent(_ component: LECSComponent) -> LECSComponentId {
        // critical region?
        let id = LECSComponentId(components.count)
        components[type(of: component)] = id // might have to cast to Any, see type(of:) help

        return id
    }

    private func column(componentId: LECSComponentId, archetypeId: LECSArchetypeId) -> LECSArchetypeColumn? {
        componentArchetype[componentId]?[archetypeId]
    }

    private func createArchetype(id: LECSArchetypeId, type: [LECSComponentId], components: [LECSComponent.Type]) -> LECSArchetype {
        // invalidate the query cache, since the new archetype may have components in one of the indexes
        queryCache = [:]
        
        return factory.create(id: id, type: type, components: components)
    }

    private func queryHash(_ query: [LECSComponentId]) -> String {
        query.map { String($0.hashValue) }.joined(separator: ":")
    }
}

struct LECSArchetypeFactory {
    let size: Int

    func create(id: LECSArchetypeId, type: [LECSComponentId], components: [LECSComponent.Type]) -> LECSArchetype {

        return LECSArchetype(id: id, type: type, table: LECSSparseArrayTable(size: size, componentTypes: components))
    }
}
