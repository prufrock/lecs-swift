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
    func hasComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) -> Bool

    func getComponent<T: LECSComponent>(_ entityId: LECSEntityId) -> T

    // MARK: Components
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, component: T)

    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    // MARK: Systems
    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSEntityId

    func process(_ system: LECSEntityId)
}

class LECSWorldActual {
    private var entityCounter: LECSEntityId = 0
    private var entityComponent: [LECSEntityId: Set<MetatypeWrapper>] = [:]
    private var entityRecord: [LECSEntityId: LECSRecord] = [:]
    private var idNameArchetype: LECSArchetype

    // indexes
    private var idComponent: LECSComponentId
    private var nameComponent: LECSComponentId
    private var typeComponent: [MetatypeWrapper: LECSEntityId] = [:]

    init() {
        idComponent = entityCounter
        typeComponent[LECSId.self] = idComponent
        entityCounter += 1
        nameComponent = entityCounter
        typeComponent[LECSName.self] = nameComponent
        entityCounter += 1

        let id = entityCounter
        entityCounter += 1
        idNameArchetype = LECSArchetype(
            id: id,
            type: [idComponent, nameComponent],
            columns: [LECSId.self, LECSName.self],
            size: 10
        )
    }

    func createEntity(_ name: String) throws -> LECSEntityId {
        let id = entityCounter
        entityCounter += 1

        var set: Set<MetatypeWrapper> = Set()
        set.insert(LECSId.self)
        set.insert(LECSName.self)
        entityComponent[id] = set

        let rowId = try idNameArchetype.insert([LECSId(id: id), LECSName(name: name)])

        entityRecord[id] = LECSRecord(entityId: id, archetype: idNameArchetype, row: rowId)

        return id
    }

    // MARK: Querying Entities
    func hasComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) -> Bool {
        return entityComponent[entityId]?.contains(component) ?? false
    }

    func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T? {
        let record = entityRecord[entityId]!
        let archetype = record.archetype

        var component: T? = nil

        if let componentIndex = archetype.type.firstIndex(of: typeComponent[T.self]!) {
            let row = try archetype.read(record.row)
            component = row[componentIndex] as? T
        }


        return component
    }
}
