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
//    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    // MARK: Systems
//    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSEntityId

//    func process(_ system: LECSEntityId)
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
    private var emptyArchetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
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

    init(archetypeSize: LECSSize = 10) {
        self.archetypeSize = archetypeSize

        entityRecord[rootEntity] = LECSRecord(
            entityId: rootEntity,
            archetype: emptyArchetype,
            row: 0
        )
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
        // TODO: replace with a faster search
        // Check to see if the entity has the component
        return entityRecord[entityId]?.hasComponent(componentId) ?? false
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
}
