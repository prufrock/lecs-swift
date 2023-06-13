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
typealias LECSSize = Int
typealias LECSRowId = Int
typealias LECSRow = [LECSComponent]

class LECSArchetype {
    let id: LECSArchetypeId
    let type: LECSType
    let table: LECSTable

    init(id: LECSArchetypeId, type: LECSType, table: LECSTable) {
        self.id = id
        self.type = type
        self.table = table
    }
}

struct LECSTable {
    private var rows: Data
    let elementSize: LECSSize
    let size: LECSSize
    private (set) var count: LECSSize
    private var offset: LECSSize {
        count * elementSize
    }

    init(elementSize: LECSSize, size: LECSSize) {
        self.elementSize = elementSize
        self.size = size

        rows = Data(count: elementSize * size)
        count = 0
    }

    mutating func add(_ row: Data) {
        rows.replaceSubrange(offset..<(offset + elementSize), with: row)
        count += 1
    }

    func read(_ rowId: LECSRowId) -> Data {
        rows.subdata(in: (rowId * elementSize)..<(rowId * elementSize + elementSize))
    }
}
