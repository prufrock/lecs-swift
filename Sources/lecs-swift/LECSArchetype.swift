//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

typealias LECSEntityId = UInt
typealias LECSArchetypeId = LECSEntityId
typealias LECSComponentId = LECSEntityId
typealias LECSType = [LECSComponentId]
typealias LECSSize = UInt

class LECSArchetype {
    let id: LECSArchetypeId
    let type: LECSType

    init(id: LECSArchetypeId, type: LECSType) {
        self.id = id
        self.type = type
    }
}

struct LECSTable {
    let elements: Data
    let elementSize: LECSSize
    let count: LECSSize
    let size: LECSSize
}
