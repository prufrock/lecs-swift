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

    func getComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) -> Bool

    // MARK: Components
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, component: T)

    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    // MARK: Systems
    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSEntityId

    func process(_ system: LECSEntityId)
}

class LECSWorldActual {
    private var entityCounter: LECSEntityId = 0

    func createEntity(_ name: String) -> LECSEntityId {
        entityCounter += 1
        return entityCounter
    }
}
