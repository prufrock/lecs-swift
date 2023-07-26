//
//  File.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

protocol RowManager: Sequence {
    /// An empty row. The rows do not have to be consecutive.
    /// - Returns: The next available empty row, if there is one otherwise nil.
    mutating func emptyRow() -> LECSRowId?


    /// Makes the rowId available to be assigned again.
    /// - Returns: Whether or not the row was freed.
    mutating func freeRow(_ rowId: LECSRowId) -> Bool

    // Useful if you want to know if a row is available.
    // - Returns: Whether or not the row is vacant.
    func vacant(_ rowId: LECSRowId) -> Bool
}
