//
//  LECSComponentChart.swift
//
//
//  Created by David Kanenwisher on 3/19/24.
//

import Foundation

/// Stores Components grouped into Archetypes as rows.
protocol LECSComponentChart {
    /// Creates a row in the ComponentChart.
    func createRow() -> LECSCCRowId

    /// Reads Component of the type from the given row.
    func readComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type)

    /// Deletes the row.
    func delete(row rowId: LECSRowId)

    /// Adds the LECSCCComponent to the row.
    /// This makes the provided LECSCCRowId stale, so the caller needs to use the return LECSCCRowId.
    func addComponentTo(row rowId: LECSRowId, component: LECSComponent) -> LECSCCRowId

    /// Removes the LECSCCComponent from the row.
    /// This makes the provided LECSCCRowId stale, so the caller needs to use the return LECSRowId.
    func removeComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) -> LECSCCRowId

    /// Read all rows that have the Components in the query.
    /// For now, need to use LECSCCColumns to read from LECSCCRowId in the order of LECSQuery: LECSRow[LECSCColumns[0].col]
    func select(query: LECSQuery, block: (LECSRow, LECSColumns) -> Void)

    /// Allows updates of the LECSRows selected by the LECSQuery.
    /// The block should return the modified LECSRow to be stored in the ComponentChart.
    func update(query: LECSQuery, block: (LECSRow, LECSColumns) -> LECSRow)
}

/// A LECSFixedComponentChart is a ComponentChart that has a fixed size.
class LECSFixedComponentChart {
    func createRow() -> LECSCCRowId {
        return LECSCCRowId(id: 0, archetypeId: LECSArchetypeId(id: 0))
    }

    func readComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) {

    }

    func delete(row rowId: LECSRowId) {

    }

    func addComponentTo(row rowId: LECSRowId, component: LECSComponent) -> LECSCCRowId {
        return LECSCCRowId(id: 0, archetypeId: LECSArchetypeId(id: 0))
    }

    func removeComponentFrom<T: LECSComponent>(row rowId: LECSRowId, type: T.Type) -> LECSCCRowId {
        return LECSCCRowId(id: 0, archetypeId: LECSArchetypeId(id: 0))
    }

    func select(query: LECSQuery, block: (LECSRow, LECSColumns) -> Void) {

    }

    func update(query: LECSQuery, block: (LECSRow, LECSColumns) -> LECSRow) {

    }
}
