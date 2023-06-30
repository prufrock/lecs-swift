//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

protocol LECSWorld {
    // MARK: Entities
    func createEntity(_ name: String) -> LECSEntityId

    // MARK: Querying Entities
    func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool

    func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T?

    // MARK: Components
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, component: T)

    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    // MARK: Systems
    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSEntityId

    func process(_ system: LECSEntityId)
}

enum LECSWorldErrors: Error {
    case entityDoesNotExist
}

class LECSWorldActual {
    private var entityCounter: LECSEntityId = 2

    private var rootEntity: LECSEntityId = 0

    // archetypes
    private var emptyArchetype: LECSArchetype = LECSArchetype(
        id: 1,
        type: [],
        columns: [],
        table: LECSTable(elementSize: 0, size: 0)
    )

    // indexes
    private var entityRecord: [LECSEntityId: LECSRecord] = [:]
    private var typeComponent: [MetatypeWrapper: LECSComponentId] = [:]

    init() {
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
        let row = try oldArchetype.remove(record.row)
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
        entityRecord[id] = LECSRecord(
            entityId: id,
            archetype: emptyArchetype,
            row: 0 // always 0 because there is nothing to store
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
        return LECSArchetype(
            id: id,
            type: type,
            columns: columns,
            //TODO: set a global size until you figure out a way to determine sizes
            size: 10
        )
    }
}
