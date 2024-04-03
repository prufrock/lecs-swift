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
class LECSArchetype<Table: LECSTable>: Sequence {
    let id: LECSArchetypeId
    private let type: [LECSComponentId]
    private let table: Table
    private let edges: [LECSComponentId:LECSArchetypeId] = [:]
    private var componentTypes: [LECSComponent.Type] {
        get {
            table.componentTypes
        }
    }

    init(
        id: LECSArchetypeId,
        type: [LECSComponentId],
        table: Table
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

    func insert(row: LECSRow) -> LECSRowId {
        LECSRowId(archetypeId: id, id: table.insert(row))
    }

    func makeIterator() -> Table.Iterator {
        table.makeIterator()
    }
}

/// The unique identifier of an Archetype or of an Archetype you'd like there to be.
struct LECSArchetypeId: RawRepresentable, Equatable {
    var rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(id: Int) {
        self.init(rawValue: id)
    }
}

// The column the LECSComponent is stored in a LECSArchetype.
struct LECSArchetypeColumn {
    let col: Int
}

typealias LECSColumns = [LECSArchetypeColumn]
