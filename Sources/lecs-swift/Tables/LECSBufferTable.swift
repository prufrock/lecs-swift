//
//  LECSBufferTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

struct LECSBufferTable: LECSTable {
    private var rows: Data
    fileprivate let elementSize: LECSSize
    fileprivate let size: LECSSize
    private let columns: LECSColumnTypes
    private var rowManager = RecyclingRowManager()
    var count: LECSSize  {
        rowManager.count
    }

    private var removed: Set<LECSRowId> = []

    init(elementSize: LECSSize, size: LECSSize, columns: LECSColumnTypes) {
        self.elementSize = elementSize
        self.size = size
        rows = Data(count: elementSize * size)
        self.columns = columns
    }

    func read(_ rowId: LECSRowId) throws -> LECSRow? {
        guard let data = readData(rowId) else {
            return nil
        }
        let decoder = LECSRowDecoder(data)
        return try decoder.decode(types: columns)
    }

    mutating func update(_ rowId: LECSRowId, column: Int, component: LECSComponent) throws {
        var row = try read(rowId)!
        row[column] = component
        let encoder = LECSRowEncoder(elementSize)
        let data = try encoder.encode(row)
        try writeToBuffer(rowId, data)
    }

    mutating func insert(_ values: LECSRow) throws -> LECSRowId {
        let encoder = LECSRowEncoder(elementSize)
        let data = try! encoder.encode(values)

        let row = emptyRow()

        try writeToBuffer(row, data)

        return row
    }

    mutating func remove(_ id: Int)  {
        removed.insert(id)
    }

    func makeIterator() -> Iterator {
        return Iterator(rowManager.makeIterator())
    }

    struct Iterator: IteratorProtocol {
        private var iterator: RowIterator

        init(_ iterator: RowIterator) {
            self.iterator = iterator
        }

        mutating func next() -> LECSSize? {
            iterator.next()
        }
    }

    mutating private func emptyRow() -> LECSRowId {
        return rowManager.emptyRow()!
    }

    private func offset(_ row: LECSRowId) -> Int {
        row * elementSize
    }

    private func readData(_ rowId: LECSRowId) -> Data? {
        guard !removed.contains(rowId) else {
            return nil
        }

        return rows.subdata(in: (rowId * elementSize)..<(rowId * elementSize + elementSize))
    }

    private mutating func writeToBuffer(_ row: LECSRowId, _ values: Data) throws {
        let offset = offset(row)
        rows.replaceSubrange(offset..<(offset + elementSize), with: values)
    }
}

struct RecyclingRowManager: RowManager {
    private(set) var count: LECSSize
    private var freed: Set<LECSSize>

    init(initialRowId: Int = 0, freed: Set<LECSSize> = Set<LECSSize>()) {
        count = initialRowId
        self.freed = freed
    }

    mutating func emptyRow() -> LECSRowId? {
        if let rowId = freed.popFirst() {
            return rowId
        }

        defer {
            count = count + 1
        }

        return count
    }

    mutating func freeRow(_ rowId: LECSRowId) -> Bool {
        freed.insert(rowId)
        return true
    }

    func makeIterator() -> RowIterator {
        RowIterator(count: count)
    }

    func vacant(_ rowId: LECSRowId) -> Bool {
        rowId > count || freed.contains(rowId)
    }
}

struct RowIterator: IteratorProtocol {
    private let count: LECSSize
    private var index = 0

    init(count: LECSSize) {
        self.count = count
    }

    mutating func next() -> LECSSize? {
        if index >= count {
            index = 0
            return nil
        }

        defer {
            index = index + 1
        }

        //TODO: skip freed elements
        return index
    }
}
