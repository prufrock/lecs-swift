//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/25/23.
//

import Foundation

struct LECSRecord {
    let entityId: LECSEntityId
    let archetype: LECSArchetype
    let row: LECSRowId

    func hasComponent(_ component: LECSComponentId) -> Bool {
        archetype.hasComponent(component)
    }

    func getComponent<T>(_ entityId: LECSEntityId, _ componentId: LECSComponentId, _ type: T.Type) throws -> T? {
        return archetype.getComponent(rowId: row, componentId: componentId, componentType: type)
    }
}
