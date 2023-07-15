//
//  LECSWorld.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

/**
 The world is the facade for the ECS system. All or nearly all access to the ECS system goes through world.
 */
protocol LECSWorld {
    // MARK: Entities

    /// Creates an entity, adds it to the ECS, and returns its id.
    /// - Parameter name: The name of the entity.
    /// - Returns: The id of the new entity.
    func createEntity(_ name: String) throws -> LECSEntityId

    // MARK: Querying Entities
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

    // MARK: Components
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

    // MARK: Systems
    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSSystemId

    func process(system: LECSSystemId)
}

enum LECSWorldErrors: Error {
    case entityDoesNotExist
    case rowDoesNotExist
}

class LECSWorldFixedSize: LECSWorld {
    private let archetypeSize: LECSSize

    private var entityCounter: LECSEntityId = 2

    private var rootEntity: LECSEntityId = 0

    // archetypes
    private var emptyArchetype: LECSArchetype = LECSArchetypeFixedSize(
        id: 1,
        type: [],
        columns: [],
        table: LECSTable(elementSize: 0, size: 0)
    )

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

    init(archetypeSize: LECSSize = 10) {
        self.archetypeSize = archetypeSize

        entityRecord[rootEntity] = LECSRecord(
            entityId: rootEntity,
            archetype: emptyArchetype,
            row: 0
        )

        archetypeIndex[emptyArchetype.id] = emptyArchetype
    }

    func createEntity(_ name: String) throws -> LECSEntityId {
        let id = createEntity()

        try addComponent(id, LECSId(id: id))
        try addComponent(id, LECSName(name: name))

        return id
    }

    // MARK: Querying Entities
    func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool {
        // Find the id of the component
        guard let componentId = typeComponent[component] else {
            return false
        }
        guard let archetype = entityRecord[entityId]?.archetype else {
            return false
        }
        return componentArchetype[componentId]?[archetype.id] != nil
    }

    func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T? {
        let record = entityRecord[entityId]!

        return try record.getComponent(entityId, typeComponent[T.self]!, T.self)
    }

    //MARK: Components
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T) throws {
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
            //TODO: Do I need to keep the columns sorted by componentId?
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

    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) {
        fatalError("not implemented")
    }

    // MARK: Systems
    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSSystemId {
        fatalError("not implemented")
    }

    func process(system: LECSSystemId) {
        fatalError("not implemented")
    }

    func select(_ query: [LECSComponent.Type], _ block: (LECSWorld, [LECSComponent]) -> Void) {
        // If there aren't any components in the query there is no work to be done.
        guard query.isNotEmpty else {
            return
        }

        for (archetypeId, archetypeRecords) in findArchetypesWithComponents(query) {
            let archetype = archetypeIndex[archetypeId]!
            try! archetype.readAll { row in
                var components: [LECSComponent] = []
                archetypeRecords.forEach { archetypeRecord in
                    components.append(row[archetypeRecord.column])
                }
                block(self, components)
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

    private func createArchetype(columns: LECSColumns, type: LECSType) -> LECSArchetype {
        let id = entity()
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

    private func findArchetypesWithComponent(_ component: LECSComponent.Type) -> LECSArchetypeMap {
        componentArchetype[typeComponent[component]!]!
    }

    private func findArchetypesWithComponents(_ components: [LECSComponent.Type]) -> [LECSArchetypeId:[LECSArchetypeRecord]] {
        // stores one and only one of each archetype
        // knows the location of each component in each archetype
        var archetypePositions: [LECSArchetypeId:[LECSArchetypeRecord]] = [:]

        // Find the archetype that matches the query
        // Process in component order so they can be read out in order
        components.forEach { componentType in
            findArchetypesWithComponent(componentType).forEach { archetypeId, archetypeRecord in
                archetypePositions.updateCollection(archetypeRecord, forKey: archetypeId)
            }
        }

        return archetypePositions
    }
}

struct LECSArchetypeRecord{
    let column: Int
}
typealias LECSArchetypeMap = [LECSArchetypeId: LECSArchetypeRecord]
