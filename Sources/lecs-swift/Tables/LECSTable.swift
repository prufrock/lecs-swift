//
//  LECSTable.swift
//
//
//  Created by David Kanenwisher on 3/27/24.
//

import Foundation

// TODO: need to sort out terminology on components vs row
public typealias LECSRow = [LECSComponent]

protocol LECSTable: Sequence where Iterator.Element == LECSAddressableRow {

    /// The number of items in the table.
    var count: Int { get }

    // The largest index assigned so far.
    var largestIndex: Int { get }

    /// The maximum number of elements the table can hold.
    var size: Int { get }

    var items: [LECSRow] { get }

    /// The ordered list of Component types that together comprise the table's and it's Archetype's "type".
    var componentTypes: [LECSComponent.Type] { get }

    /// Create a new row in the table.
    func create() -> Int

    /// Insert a LECSRow into the table
    func insert(_ components: LECSRow) -> Int

    /// Read the row at index i.
    func read(_ i: Int) -> LECSRow

    /// Update a specific column of row i with the component.
    @discardableResult
    func update(row i: Int, column: Int, component: LECSComponent) -> [LECSComponent]

    /// Update all of the components of row i.
    @discardableResult
    func update(row i: Int, components: LECSRow) -> LECSRow

    /// Delete row i.
    @discardableResult
    func delete(_ i: Int) -> LECSRow

    /// Check to see if row i exists.
    func exists(_ i: Int) -> Bool

    func makeIterator() -> AnyIterator<LECSAddressableRow>
}

class LECSSparseArrayTable: LECSTable {

    //TODO: redundant, but worth reflecting on
    typealias Element = LECSAddressableRow

    let size: Int
    let componentTypes: [LECSComponent.Type]
    fileprivate var index: Int = 0
    private var deleted: Set<Int> = []
    var items: [[LECSComponent]]

    init(size: Int, componentTypes: [LECSComponent.Type]) {
        self.size = size
        self.componentTypes = componentTypes
        var row: LECSRow = []
        for i in 0..<componentTypes.count {
            let componentType = componentTypes[i]
            row.append(componentType.init())
        }
        self.items = Array(repeating: row, count: size)
    }

    var count: Int {
        return index - deleted.count
    }

    var largestIndex: Int {
        return index
    }

    func create() -> Int {
        return nextRow()
    }

    func insert(_ components: [LECSComponent]) -> Int {
        let i = nextRow()
        items[i] = components
        return i
    }

    func read(_ i: Int) -> [LECSComponent] {
        throwIfRowDoesNotExist(i)
        return items[i]
    }

    func update(row i: Int, column: Int, component: LECSComponent) -> [LECSComponent] {
        throwIfRowDoesNotExist(i)
        items[i][column] = component
        return items[i]
    }

    func update(row i: Int, components: [LECSComponent]) -> [LECSComponent] {
        throwIfRowDoesNotExist(i)
        items[i] = components
        return items[i]
    }

    @discardableResult
    func delete(_ i: Int) -> [LECSComponent] {
        throwIfRowDoesNotExist(i)
        deleted.insert(i)
        return items[i]
    }

    func exists(_ i: Int) -> Bool {
        return i < index && !deleted.contains(i)
    }

    private func throwIfRowDoesNotExist(_ i: Int) {
        if i > index {
            fatalError("Row \(i) couldn't be found in the table. Did the row get created?")
        }
        if deleted.contains(i) {
            fatalError("Row \(i) couldn't be found in the table. It has been deleted. This tends to happen after a component is added or removed and the old LECSRowId is used instead of the new one.")
        }
    }

    private func nextRow() -> Int {
        if let firstDeletedIndex = deleted.first {
            deleted.remove(firstDeletedIndex)
            return firstDeletedIndex
        }
        if index >= size {
            fatalError("Table is full. Someone attempted to add another row to the table, but it couldn't be added because it's full.")
        }
        index += 1
        return index - 1
    }

    func makeIterator() -> AnyIterator<LECSAddressableRow> {
        return AnyIterator(SparseArrayTableIterator(self))
    }
}

struct SparseArrayTableIterator: IteratorProtocol {
    typealias Element = LECSAddressableRow

    private var table: LECSSparseArrayTable
    private var i = 0

    init(_ table: LECSSparseArrayTable) {
        self.table = table
    }

    private mutating func hasNext() -> Bool {
        // mind the gaps
        while(i < table.index && !table.exists(i)) {
            i += 1
        }
        return i < table.index
    }

    mutating func next() -> Element? {
        if (hasNext()) {
            let current = i
            i += 1
            return LECSAddressableRow(index: current, row: table.read(current))
        } else {
            return nil
        }
    }
}

struct LECSAddressableRow {
    let index: Int
    var row: LECSRow

    func update(_ newRow: LECSRow) -> LECSAddressableRow {
        LECSAddressableRow(index: index, row: newRow)
    }

    func update(for columns: LECSColumns, changes: LECSRow) -> LECSAddressableRow {
        var newRow = row
        for i in columns.indices {
            newRow[columns[i].col] = changes[i]
        }

        return LECSAddressableRow(index: index, row: newRow)
    }

    mutating func update(forColumns columns: LECSColumns, changes: LECSRow) {
        for i in columns.indices {
            row[columns[i].col] = changes[i]
        }
    }
}

extension LECSRow {
    public func component<T: LECSComponent>(at index: Int, _ columns: LECSColumns, _ component: T.Type) -> T {
        self[columns[index].col] as! T
    }
}
