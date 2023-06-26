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

class LECSWorldActual {
    private var entityCounter: LECSEntityId = 0

    // archetypes
    private var idNameArchetype: LECSArchetype? = nil

    // indexes
    private var entityRecord: [LECSEntityId: LECSRecord] = [:]
    private var typeComponent: [MetatypeWrapper: LECSComponentId] = [:]

    func createEntity(_ name: String) throws -> LECSEntityId {
        let id = entity()

        // create the components
        let idComponent = entity()
        typeComponent[LECSId.self] = idComponent
        let nameComponent = entity()
        typeComponent[LECSName.self] = nameComponent

        // if idNameArchetype is nil create it
        if idNameArchetype == nil {
            // create the archetype
            idNameArchetype = LECSArchetype(
                id: entity(),
                type: [idComponent, nameComponent],
                columns: [LECSId.self, LECSName.self],
                size: 10
            )
        }

        let rowId = try idNameArchetype!.insert([LECSId(id: id), LECSName(name: name)])

        entityRecord[id] = LECSRecord(entityId: id, archetype: idNameArchetype!, row: rowId)

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

    private func entity() -> LECSEntityId {
        let id = entityCounter
        entityCounter += 1
        return id
    }
}
