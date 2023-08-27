//
//  LECSArrayTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

/// Stores components in an array.
struct LECSArrayTable: LECSTable {
    public let size: LECSSize
    public var rows: [LECSRow]
    private var rowManager = RecyclingRowManager()
    private var isFake: Bool {
        get {
            size == 0
        }
    }
    private var notFake: Bool {
        get {
            size != 0
        }
    }
    var count: LECSSize {
        rowManager.count
    }

    init(size: LECSSize, columnTypes: LECSColumnTypes) {
        self.size = size

        var tempRows: [LECSRow] = []
        for _ in 0..<size {
            var row: LECSRow = []
            for i in 0..<columnTypes.count {
                let componentType = columnTypes[i]
                row.append(componentType.init())
            }
            tempRows.append(row)
        }

        rows = tempRows
    }

    func exists(_ rowId: LECSRowId) -> Bool {
        return rowId < size && !rowManager.vacant(rowId)
    }

    func read(_ rowId: LECSRowId) throws -> LECSRow? {
        // for the empty archetype that has nothing to read from it
        if isFake {
            return []
        }
        
        guard exists(rowId) else {
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

    mutating private func emptyRow() -> LECSRowId {
        return rowManager.emptyRow()!
    }

    mutating private func writeToArrays(_ row: LECSSize, _ values: LECSRow) {
        guard notFake else {
            return
        }
        rows[row] = values
    }

    mutating private func writeToColumn(_ row: LECSSize, column: LECSColumn, value: LECSComponent) {
        guard notFake else {
            return
        }
        rows[row][column] = value
    }
}
