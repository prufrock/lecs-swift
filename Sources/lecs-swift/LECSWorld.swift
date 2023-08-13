//
//  LECSWorld.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

public typealias LECSEntityId = UInt
public typealias LECSArchetypeId = LECSEntityId
public typealias LECSComponentId = LECSEntityId
public typealias LECSSystemId = LECSEntityId
public typealias LECSType = [LECSComponentId]
public typealias LECSSize = Int
public typealias LECSRowId = Int
public typealias LECSRow = [LECSComponent]
public typealias LECSColumns = [LECSColumn]
public typealias LECSColumn = Int
public typealias LECSQuery = LECSType
public typealias LECSColumnPositions = [Int]

/// The world is the facade for the ECS system. All or nearly all access to the ECS system goes through LECSWorld.
public protocol LECSWorld {
    /// Creates an entity, adds it to the ECS, and returns its id.
    /// - Parameters:
    ///   - name: The name of the entity.
    /// - Returns: The id of the new entity.
    func createEntity(_ name: String) throws -> LECSEntityId

    /// Deletes the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to delete
    /// - Returns: void
    func deleteEntity(_ entityId: LECSEntityId)

    /// Checks to see if the entity has a component.
    /// - Parameters:
    ///   - entityId: The id of the entity to check.
    ///   - component: The Type of the component.
    /// - Returns: whether or not the entity has the component
    func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool

    /// Finds the component on the entity if it exists.
    /// - Parameters:
    ///   - entityId: The id of the entity to get the entity for.
    ///   - component: The Type of the component.
    /// - Returns: The component requested if it exists on the entity.
    func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T?

    /// Adds a component to the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to add the component to.
    ///   - component: The component to add to the entity.
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T) throws

    /// Removes a component from the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to remove the component from.
    ///   - component: The Type of the component to remove.
    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    /// Adds a system to the world.
    /// - Parameters:
    ///   - name: The name of the system.
    ///   - selector: The query of component Ids selecting entities to process with the system.
    ///   - block: The closure to run on the results of the query.
    /// - Returns: The id of the system.
    func addSystem(_ name: String, selector: LECSQuery, block: @escaping (LECSWorld, LECSRow, LECSColumnPositions) -> [LECSComponent]) -> LECSSystemId

    /// Adds a system to the world.
    /// - Parameters:
    ///   - name: The name of the system.
    ///   - selector: The query of component types selecting entities to process with the system.
    ///   - block: The closure to run on the results of the query.
    /// - Returns: The id of the system.
    func addSystem(_ name: String, selector: [LECSComponent.Type], block: @escaping (LECSWorld, LECSRow, [Int]) -> [LECSComponent]) -> LECSSystemId

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component Ids selecting entities.
    ///   - block: The closure to run on the resulting data.
    func select(_ query: LECSQuery, _ block: (LECSWorld, LECSRow, LECSColumns) -> Void)

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component types selecting entities.
    ///   - block: The closure to run on the resulting data.
    func select(_ query: [LECSComponent.Type], _ block: (LECSWorld, LECSRow, LECSColumns) -> Void)

    /// Executes the system.
    /// - Parameters:
    ///   - system: The system to run.
    func process(system: LECSSystemId)
}

enum LECSWorldErrors: Error {
    case entityDoesNotExist
    case rowDoesNotExist
}

/// Create a LECSWorld with archetypes of size.
/// - Parameters
///   - archetypeSize: The size of the archetypes in LECSWorld.
public func LECSCreateWorld(archetypeSize: LECSSize = 2000) -> LECSWorld {
    return LECSWorldFixedSize(archetypeSize: archetypeSize)
}

public class LECSWorldFixedSize: LECSWorld {
    private let archetypeSize: LECSSize

    private var entityCounter: LECSEntityId = 2

    private var rootEntity: LECSEntityId = 0

    // archetypes
    private var emptyArchetype: LECSArchetype = LECSArchetypeFixedSize(
        id: 1,
        type: [],
        columns: [],
        table: LECSArrayTable(size: 0, columns: [])
    )

    //systems
    private var systems: [LECSSystemId: LECSSystem] = [:]

    // indexes
    // entityRecord is a map of entity ids to records. The record contains the archetype and the row id.
    private var entityRecord: [LECSEntityId: LECSRecord] = [:]
    // typeComponent maps the Swift Type of a Component to a ComponentId
    private var typeComponent: [MetatypeWrapper: LECSComponentId] = [:]
    // archetypeIndex maps archetype ids to archetypes
    private var archetypeIndex: [LECSArchetypeId: LECSArchetype] = [:]
    // componentArchetype maps component ids to the archetypes their in and the column they are in.
    // this makes determining if a component is in an archetype and retrieval fast
    private var componentArchetype: [LECSComponentId : LECSArchetypeMap] = [:]

    public init(archetypeSize: LECSSize = 10) {
        self.archetypeSize = archetypeSize

        entityRecord[rootEntity] = LECSRecord(
            entityId: rootEntity,
            archetype: emptyArchetype,
            row: 0
        )

        archetypeIndex[emptyArchetype.id] = emptyArchetype
    }

    public func createEntity(_ name: String) throws -> LECSEntityId {
        let id = createEntity()

        try addComponent(id, LECSId(id: id))
        try addComponent(id, LECSName(name: name))

        return id
    }

    public func deleteEntity(_ entityId: LECSEntityId) {
        guard let record = entityRecord[entityId], var archetype = archetypeIndex[record.archetype.id] else {
            return
        }

        archetype.table.remove(record.row)
    }

    public func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool {
        // Find the id of the component
        guard let componentId = typeComponent[component] else {
            return false
        }
        guard let archetype = entityRecord[entityId]?.archetype else {
            return false
        }
        return componentArchetype[componentId]?[archetype.id] != nil
    }

    public func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T? {
        let record = entityRecord[entityId]!

        return try record.getComponent(entityId, typeComponent[T.self]!, T.self)
    }

    public func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T) throws {
        // Get the entity's record
        // Remove the row from the archetype returning the value
        // Retrieve the next archetype:
        //   Check to see if the record has an add edge to the new component
        //     If it does use the archetype on the add edge
        //     If it does not create a new archetype for the records components + the new component
        //        Add the new archetype to the add edge of the old archetype
        //        Add old archetype as a remove edge on the new archetype
        //   At this point you have an archetype
        //     Insert the components into the archetype
        //     Create a new record with new archetype and row id
        guard let record = entityRecord[entityId] else {
            throw LECSWorldErrors.entityDoesNotExist
        }

        let oldArchetype = record.archetype
        guard let row = try oldArchetype.remove(record.row) else {
            throw LECSWorldErrors.rowDoesNotExist
        }
        let componentId = typeComponent[T.self] ?? createComponent(T.self)

        let newArchetype = oldArchetype.addComponent(componentId) ?? createArchetype(
            columns: oldArchetype.columns + [T.self],
            type: oldArchetype.type + [componentId]
        )
        oldArchetype.setAddEdge(componentId, newArchetype)
        newArchetype.setRemoveEdge(componentId, oldArchetype)

        let newRow = try newArchetype.insert(row + [component])

        entityRecord[entityId] = LECSRecord(
            entityId: entityId,
            archetype: newArchetype,
            row: newRow
        )

        updateComponentArchetypeMap(newArchetype)
        archetypeIndex[newArchetype.id] = newArchetype
    }

    public func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) {
        fatalError("not implemented")
    }

    public func addSystem(_ name: String, selector: [LECSComponentId], block: @escaping (LECSWorld, LECSRow, [Int]) -> [LECSComponent]) -> LECSSystemId {
        let system = LECSSystem(name: name, selector: selector, lambda: block)
        let id = entity()
        systems[id] = system
        return id
    }

    public func addSystem(_ name: String, selector: [LECSComponent.Type], block: @escaping (LECSWorld, LECSRow, [Int]) -> [LECSComponent]) -> LECSSystemId {
        addSystem(name, selector: selector.map{ typeComponent[$0]! }, block: block)
    }

    public func process(system id: LECSSystemId) {
        let system = systems[id]!
        update(system.selector) { world, components, columns in
            return system.lambda(world, components, columns)
        }
    }

    public func select(_ query: [LECSComponent.Type], _ block: (LECSWorld, LECSRow, LECSColumns) -> Void) {
        select(query.map{ typeComponent[$0]! }, block)
    }

    public func select(_ query: LECSQuery, _ block: (LECSWorld, LECSRow, LECSColumns) -> Void) {
        // If there aren't any components in the query there is no work to be done.
        guard query.isNotEmpty else {
            return
        }

        for (archetypeId, archetypeRecords) in findArchetypesWithComponents(query) {
            let archetype = archetypeIndex[archetypeId]!
            (0..<archetype.table.count).forEach { rowId in
                let columns: [Int] = archetypeRecords.map { $0.column }
                if archetype.table.exists(rowId) {
                    block(self, archetype.table.rows[rowId], columns)
                }
            }
        }
    }

    private func update(_ query: LECSQuery, _ block: (LECSWorld, LECSRow, LECSColumns) -> [LECSComponent]) {
        // If there aren't any components in the query there is no work to be done.
        guard query.isNotEmpty else {
            return
        }

        for (archetypeId, archetypeRecords) in findArchetypesWithComponents(query) {
            var archetype = archetypeIndex[archetypeId]!
            (0..<archetype.table.count).forEach { rowId in
                let columns: [Int] = archetypeRecords.map { $0.column }
                if archetype.table.exists(rowId) {
                    let updatedComponents = block(self, archetype.table.rows[rowId], columns)
                    var uc = 0
                    columns.forEach {
                        archetype.table.rows[rowId][$0] = updatedComponents[uc]
                        uc += 1
                    }
                }
            }
        }
    }

    private func entity() -> LECSEntityId {
        let id = entityCounter
        entityCounter += 1
        return id
    }

    private func createEntity() -> LECSEntityId {
        let id = entity()
        let rowId = try! emptyArchetype.insert([])
        entityRecord[id] = LECSRecord(
            entityId: id,
            archetype: emptyArchetype,
            row: rowId
        )
        return id
    }

    private func createComponent(_ componentType: LECSComponent.Type) -> LECSComponentId {
        // Generate an id for the component
        let id = entity()
        // Store the component in the index
        typeComponent[componentType] = id

        return id
    }

    private func createArchetype(columns: LECSColumnTypes, type: LECSType) -> LECSArchetype {
        let id = entity()

        newArchetypeCreated()

        return LECSArchetypeFixedSize(
            id: id,
            type: type,
            columns: columns,
            size: archetypeSize
        )
    }

    private func updateComponentArchetypeMap(_ archetype: LECSArchetype) {
        // iterate over the type in the archetype
        for (column, componentId) in archetype.type.enumerated() {
            // get the map for the component
            var map = componentArchetype[componentId] ?? [:]
            // add the archetype to the map
            map[archetype.id] = LECSArchetypeRecord(column: column)
            // update the map in the index
            componentArchetype[componentId] = map
        }
    }

    private func findArchetypesWithComponent(_ component: LECSComponentId) -> LECSArchetypeMap {
        componentArchetype[component]!
    }

    private var queryCache: [String: [LECSArchetypeId:[LECSArchetypeRecord]]] = [:]

    private func findArchetypesWithComponents(_ query: LECSQuery) -> [LECSArchetypeId:[LECSArchetypeRecord]] {
        if let positions =  queryCache[queryHash(query)] {
            return positions
        }
        // stores one and only one of each archetype
        // knows the location of each component in each archetype
        var archetypePositions: [LECSArchetypeId:[LECSArchetypeRecord]] = [:]

        // Find the archetype that matches the query
        // Process in component order so they can be read out in order
        query.forEach { componentType in
            findArchetypesWithComponent(componentType).forEach { archetypeId, archetypeRecord in
                archetypePositions.updateCollection(archetypeRecord, forKey: archetypeId)
            }
        }

        // the number of components located in each archetype must be the same as the components queried
        let positions = archetypePositions.filter { $1.count == query.count }
        queryCache[queryHash(query)] = positions
        return positions
    }

    private func queryHash(_ query: LECSQuery) -> String {
        query.map { String($0) }.joined(separator: ":")
    }

    private func newArchetypeCreated() {
        // wipe the query cache for now, eventually it may be worth only clearing queries cached with same components as the archetype
        queryCache = [:]
    }
}

struct LECSArchetypeRecord{
    let column: Int
}
typealias LECSArchetypeMap = [LECSArchetypeId: LECSArchetypeRecord]
