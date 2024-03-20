//
//  LECSComponentChart.swift
//
//
//  Created by David Kanenwisher on 3/19/24.
//

import Foundation

protocol LECSCCComponent {

}

protocol LECSComponentChart {
    func createRow() -> LECSCCRowId

    func readComponentFrom<T: LECSCCComponent>(row rowId: LECSRowId, type: T.Type)

    func delete(row rowId: LECSRowId)

    func addComponentTo(row rowId: LECSRowId, component: LECSCCComponent) -> LECSRowId

    func removeComponentFrom<T: LECSCCComponent>(row rowId: LECSRowId, type: T.Type) -> LECSRowId

    func select(query: LECSQuery, read: (LECSRow, LECSCCColumns) -> Void)

    func update(query: LECSQuery, read: (LECSRow, LECSCCColumns) -> LECSRow)
}

struct LECSCCQuery {

}

struct LECSCCArchetypeColumn {
    
}

typealias LECSCCColumns = [LECSCCArchetypeColumn]

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
