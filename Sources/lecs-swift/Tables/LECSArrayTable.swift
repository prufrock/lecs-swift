//
//  LECSArrayTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

struct LECSArrayTable: LECSTable {
    private let size: LECSSize
    private let columns: LECSColumns
    private var rows: [[LECSComponent]]
    private var rowManager = RecyclingRowManager()
    var count: LECSSize {
        rowManager.count
    }

    init(size: LECSSize, columns: LECSColumns) {
        self.size = size
        self.columns = columns

        var tempRows: [[LECSComponent]] = []
        for i in 0..<columns.count {
            let componentType = columns[i]
            tempRows.append(Array(repeating: componentType.init(), count: size))
        }

        rows = tempRows
    }

    func read(_ rowId: LECSRowId) throws -> LECSRow? {
        // for the empty archetype that has nothing to read from it
        if columns.isEmpty {
            return []
        }

        guard rowId < size || rowManager.vacant(rowId) else {
            return nil
        }

        return columns.indices.map { rows[$0][rowId] }
    }

    mutating func update(_ rowId: LECSRowId, column: Int, component: LECSComponent) throws {
        if var row = try read(rowId) {
            row[column] = component

            writeToArrays(rowId, row)
        }
    }

    mutating func insert(_ values: LECSRow) throws -> LECSRowId {
        let rowId = emptyRow()

        writeToArrays(rowId, values)

        return rowId
    }

    mutating func remove(_ id: Int) {
        let _ = rowManager.freeRow(id)
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

    mutating private func writeToArrays(_ row: LECSSize, _ values: LECSRow) {
        columns.indices.forEach {
            rows[$0][row] = values[$0]
        }
    }
}
