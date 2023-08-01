//
//  LECSArrayTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

struct LECSArrayTable: LECSTable {
    private let size: LECSSize
    public let columns: LECSColumnTypes
    public var rows: [LECSRow]
    private var rowManager = RecyclingRowManager()
    var count: LECSSize {
        rowManager.count
    }

    init(size: LECSSize, columns: LECSColumnTypes) {
        self.size = size
        self.columns = columns

        var tempRows: [LECSRow] = []
        for i in 0..<size {
            var row: LECSRow = []
            for i in 0..<columns.count {
                let componentType = columns[i]
                row.append(componentType.init())
            }
            tempRows.append(row)
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
        
        return rows[rowId]
    }

    mutating func update(_ rowId: LECSRowId, column: Int, component: LECSComponent) throws {
        writeToColumn(rowId, column: column, value: component)
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
        guard !columns.isEmpty else {
            return
        }
        rows[row] = values
    }

    mutating private func writeToColumn(_ row: LECSSize, column: LECSColumn, value: LECSComponent) {
        guard !columns.isEmpty else {
            return
        }
        rows[row][column] = value
    }
}
