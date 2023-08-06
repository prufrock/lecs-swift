//
//  LECSTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

/// Stores components in a table where each row is an entity and the columns are the components.
protocol LECSTable {
    /// The current numbers of rows in the table.
    var count: LECSSize { get }

    /// Reads the row.
    /// - Parameter rowId: The Id of the row to read from.
    /// - Returns: The row read.
    func read(_ rowId: LECSRowId) throws -> LECSRow?

    /// Checks to see if the row exists in the table.
    /// - Parameter rowId: The row to check.
    /// - Returns: Whether or not the row exists.
    func exists(_ rowId: LECSRowId) -> Bool

    /// Updates the row's column with the component.
    /// - Parameters:
    ///   - rowId: The row to update.
    ///   - column: The index of the column to update.
    ///   - component: A LECSComponent to store in the column. Be careful it is the correct type.
    mutating func update(_ rowId: LECSRowId, column: Int, component: LECSComponent) throws

    /// Inserts a row.
    /// - Parameter values: The components to insert. Be sure they are correct for this table.
    /// - Returns: The Id of the row.
    mutating func insert(_ values: LECSRow) throws -> LECSRowId

    /// Removes a row from the table.
    /// - Parameter id: The Id of the row to remove.
    mutating func remove(_ id: Int)
}
