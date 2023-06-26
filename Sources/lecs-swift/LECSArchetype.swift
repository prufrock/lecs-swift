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
typealias LECSColumns = [LECSComponent.Type]

class LECSArchetype {
    let id: LECSArchetypeId
    let type: LECSType
    private var table: LECSTable
    private let columns: LECSColumns

    //TODO: Think about ways to reduce the number of arguments on here
    init(id: LECSArchetypeId, type: LECSType, columns: LECSColumns, size: LECSSize) {
        self.id = id
        self.type = type
        self.columns = columns

        // total of all the strides of the components
        let elementSize = columns.reduce(0) { $0 + MemoryLayout.stride(ofValue: $1) }

        self.table = LECSTable(elementSize: elementSize, size: size)
    }

    init(id: LECSArchetypeId, type: LECSType, columns: LECSColumns, table: LECSTable) {
        self.id = id
        self.type = type
        self.columns = columns
        self.table = table
    }

    func insert(_ values: LECSRow) throws -> LECSRowId {
        let encoder = LECSRowEncoder(table.elementSize)
        let data = try encoder.encode(values)
        return table.insert(data)
    }

    func read(_ rowId: LECSRowId) throws -> LECSRow {
        let data = table.read(rowId)
        let decoder = LECSRowDecoder(data)
        return try decoder.decode(types: columns)
    }

    func hasComponent(_ component: LECSComponentId) -> Bool {
        type.contains(component) 
    }

    func getComponent<T>(rowId: LECSRowId, componentId: LECSComponentId, componentType: T.Type) throws -> T? {
        var component: T? = nil

        if let componentIndex = type.firstIndex(of: componentId) {
            let row = try read(rowId)
            component = row[componentIndex] as? T
        }

        return component
    }
}

struct LECSTable {
    private var rows: Data
    fileprivate let elementSize: LECSSize
    fileprivate let size: LECSSize
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

    mutating func insert(_ row: Data) -> LECSRowId {
        rows.replaceSubrange(offset..<(offset + elementSize), with: row)
        let row = count
        count += 1
        return row
    }

    func read(_ rowId: LECSRowId) -> Data {
        rows.subdata(in: (rowId * elementSize)..<(rowId * elementSize + elementSize))
    }
}
