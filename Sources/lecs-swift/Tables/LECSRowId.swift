//
//  LECSRowId.swift
//
//
//  Created by David Kanenwisher on 3/27/24.
//

import Foundation

struct LECSRowId {
    let archetypeId: LECSArchetypeId
    let id: Int
}

/// The ID of a row in an Archetype.
struct LECSCCRowId {
    let id: Int
    let archetypeId: LECSArchetypeId
}
