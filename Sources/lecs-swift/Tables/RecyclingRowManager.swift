//
//  LECSBufferTable.swift
//  
//
//  Created by David Kanenwisher on 7/25/23.
//

import Foundation

struct RecyclingRowManager: RowManager {
    private(set) var count: LECSSize
    private var freed: Set<LECSSize>

    init(initialRowId: Int = 0, freed: Set<LECSSize> = Set<LECSSize>()) {
        count = initialRowId
        self.freed = freed
    }

    mutating func emptyRow() -> LECSRowId? {
        if let rowId = freed.popFirst() {
            return rowId
        }

        defer {
            count = count + 1
        }

        return count
    }

    mutating func freeRow(_ rowId: LECSRowId) -> Bool {
        freed.insert(rowId)
        return true
    }

    func vacant(_ rowId: LECSRowId) -> Bool {
        freed.contains(rowId) || rowId > count
    }
}
