//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

protocol LECSWorld {
    func createEntity(_ name: String) -> LECSEntityId

    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, component: T)

    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    func addSystem(_ name: String, selector: [LECSComponentId], lambda: ([LECSComponent])) -> LECSEntityId

    func iterate(_ system: LECSEntityId)

    func hasComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) -> Bool
}
