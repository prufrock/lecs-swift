//
//  LECSTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

struct LECSTable: Sequence {
    private var rows: Data
    fileprivate let elementSize: LECSSize
    fileprivate let size: LECSSize
    private let columns: LECSColumns
    private var rowManager = RecyclingRowManager()
    private(set) var count: LECSSize = 0

    private var removed: Set<LECSRowId> = []

    init(elementSize: LECSSize, size: LECSSize, columns: LECSColumns) {
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

        count = count + 1

        return row
    }

    private mutating func writeToBuffer(_ row: LECSRowId, _ values: Data) throws {
        let offset = offset(row)
        rows.replaceSubrange(offset..<(offset + elementSize), with: values)
    }

    mutating func remove(_ id: Int)  {
        removed.insert(id)
        count = count - 1
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

    func makeIterator() -> Iterator {
        return Iterator(rowManager.makeIterator())
    }

    struct Iterator: IteratorProtocol {
        private var iterator: IncrementingRowManager.Iterator

        init(_ iterator: IncrementingRowManager.Iterator) {
            self.iterator = iterator
        }

        mutating func next() -> LECSSize? {
            iterator.next()
        }
    }
}

protocol RowManager: Sequence {
    /// An empty row. The rows do not have to be consecutive.
    /// - Returns: The next available empty row, if there is one otherwise nil.
    mutating func emptyRow() -> LECSRowId?


    /// Makes the rowId available to be assigned again.
    /// - Returns: Whether or not the row was freed.
    mutating func freeRow(_ rowId: LECSRowId) -> Bool
}

struct IncrementingRowManager: RowManager {
    private var count: LECSSize

    init(initialRowId: Int = 0) {
        count = initialRowId
    }

    mutating func emptyRow() -> LECSRowId? {
        let row = count
        count += 1

        return row
    }

    mutating func freeRow(_ rowId: LECSRowId) -> Bool {
        true
    }

    func makeIterator() -> RowIterator {
        RowIterator(count: count)
    }
}

struct RecyclingRowManager: RowManager {
    private var count: LECSSize
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
