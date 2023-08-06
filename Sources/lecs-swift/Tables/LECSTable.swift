//
//  LECSTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

protocol LECSTable {
    var count: LECSSize { get }

    func read(_ rowId: LECSRowId) throws -> LECSRow?

    func exists(_ rowId: LECSRowId) -> Bool

    mutating func update(_ rowId: LECSRowId, column: Int, component: LECSComponent) throws

    mutating func insert(_ values: LECSRow) throws -> LECSRowId

    mutating func remove(_ id: Int)
}
