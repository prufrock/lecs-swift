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
class LECSArchetype<Table: LECSTable> {
    let id: LECSArchetypeId
    let type: [LECSComponentId]
    let table: Table

    init(
        id: LECSArchetypeId,
        type: [LECSComponentId],
        table: Table
    ) {
        self.id = id
        self.type = type
        self.table = table
    }
}

/// The unique identifier of an Archetype or of an Archetype you'd like there to be.
struct LECSArchetypeId: RawRepresentable {
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
