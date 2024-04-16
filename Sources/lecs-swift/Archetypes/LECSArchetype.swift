//
//  LECSArchetype.swift
//
//
//  Created by David Kanenwisher on 3/27/24.
//

import Foundation

/// Needs to be a class, so they can be referenced in back and forward edges.
/// If they were copies all of the edges would have to change when an archetype changes.
/// You could use the ids as pointers to a map, but isn't that basically a manually managed reference?
/// Might be worth doing some experiments on that some day.
class LECSArchetype: Sequence {
    let id: LECSArchetypeId
    let type: [LECSComponentId]
    // Testing shows a small but noticeable improvement when using a concrete type rather than `any`. I might have to do some more experiments
    // to find a good way to generalize it while still being a concrete type. Maybe delegation?
    private let table: LECSSparseArrayTable
    var edges: [LECSComponentId:LECSArchetypeId] = [:]
    var componentTypes: [LECSComponent.Type] {
        get {
            table.componentTypes
        }
    }
    var largestIndex: Int {
        get {
            table.largestIndex
        }
    }

    init(
        id: LECSArchetypeId,
        type: [LECSComponentId],
        table: LECSSparseArrayTable
    ) {
        self.id = id
        self.type = type
        self.table = table
    }

    func createRow() -> LECSRowId {
        LECSRowId(archetypeId: id, id: table.create())
    }

    func read(_ rowId: LECSRowId) -> LECSRow {
        table.read(rowId.id)
    }

    func readRow(at index: Int) -> LECSRow {
        table.read(index)
    }

    func rowExists(at index: Int) -> Bool {
        table.exists(index)
    }

    // TODO: Is it worth returning a value here?
    @discardableResult
    func delete(_ rowId: LECSRowId) -> LECSRow {
        table.delete(rowId.id)
    }

    @discardableResult
    func update(rowId: LECSRowId, column: LECSArchetypeColumn, component: LECSComponent) -> LECSRowId {
        table.update(row: rowId.id, column: column.col, component: component)
        return rowId
    }

    // TODO: should it be row: components:?
    @discardableResult
    func update(rowId: LECSRowId, row: LECSRow) -> LECSRowId {
        table.update(row: rowId.id, components: row)
        return rowId
    }

    // TODO: does the archetypeId always need to be passed?
    func update(addressableRow: LECSAddressableRow) {
        table.update(row: addressableRow.index, components: addressableRow.row)
    }

    func update(index: Int, column: LECSArchetypeColumn, component: LECSComponent) {
        table.update(row: index, column: column.col, component: component)
    }

    func insert(row: LECSRow) -> LECSRowId {
        LECSRowId(archetypeId: id, id: table.insert(row))
    }

    func makeIterator() -> AnyIterator<LECSAddressableRow> {
        table.makeIterator()
    }
}

/// The unique identifier of an Archetype or of an Archetype you'd like there to be.
struct LECSArchetypeId: Equatable, Hashable, RawRepresentable {
    var rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(id: Int) {
        self.init(rawValue: id)
    }

    init(_ id: Int) {
        self.init(rawValue: id)
    }
}

// The column the LECSComponent is stored in a LECSArchetype.
public struct LECSArchetypeColumn {
    public let col: Int
}

public typealias LECSColumns = [LECSArchetypeColumn]
