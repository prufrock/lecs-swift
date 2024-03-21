//
//  LECSComponentChart.swift
//
//
//  Created by David Kanenwisher on 3/19/24.
//

import Foundation

/// A Component that can be stored in a ComponentChart.
protocol LECSCCComponent {

}

/// Stores Components on rows
protocol LECSComponentChart {
    /// Creates a row in the ComponentChart.
    func createRow() -> LECSCCRowId

    /// Reads Component of the type from the given row.
    func readComponentFrom<T: LECSCCComponent>(row rowId: LECSRowId, type: T.Type)

    /// Deletes the row.
    func delete(row rowId: LECSRowId)

    /// Adds the LECSCCComponent to the row.
    /// This makes the provided LECSRowId stale, so the caller needs to use the return LECSRowId.
    func addComponentTo(row rowId: LECSRowId, component: LECSCCComponent) -> LECSRowId

    /// Removes the LECSCCComponent from the row.
    /// This makes the provided LECSRowId stale, so the caller needs to use the return LECSRowId.
    func removeComponentFrom<T: LECSCCComponent>(row rowId: LECSRowId, type: T.Type) -> LECSRowId

    /// Read all rows that have the Components in the query.
    /// For now, need to use LECSCCColumns to read from LECSRow in the order of LECSQuery: LECSRow[LECSCColumns[0].col]
    func select(query: LECSQuery, block: (LECSRow, LECSCCColumns) -> Void)

    /// Allows updates of the LECSRows selected by the LECSQuery.
    /// The block should return the modified LECSRow to be stored in the ComponentChart.
    func update(query: LECSQuery, block: (LECSRow, LECSCCColumns) -> LECSRow)
}

/// Holds a list of the LECSComponents to match when querying the LECSComponentChart.
struct LECSCCCQuery {

}

// The column the LECSComponent is stored in a LECSCCCArchetype.
struct LECSCCCArchetypeColumn {
    let col: Int
}

typealias LECSCCColumns = [LECSCCCArchetypeColumn]

/// The ID of a row in an Archetype.
struct LECSCCRowId {
    let id: Int
    let archetypeId: LECSCCArchetypeId
}


/// The unique identifier of an Archetype or of an Archetype you'd like there to be.
struct LECSCCArchetypeId: RawRepresentable {
    var rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(id: Int) {
        self.init(rawValue: id)
    }
}
