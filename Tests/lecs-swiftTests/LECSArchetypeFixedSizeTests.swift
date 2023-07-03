//
//  LECSArchetypeFixedSizeTests.swift
//  
//
//  Created by David Kanenwisher on 6/15/23.
//

import XCTest
@testable import lecs_swift

final class LECSArchetypeFixedSizeTests: XCTestCase {
    var entityCounter: () -> UInt = {
        var count: UInt = 1
        return {
            count += 1
            return count
        }
    }()

    func testInsertAComponent() throws {
        let idComponent: LECSComponentId = entityCounter()
        
        let type: LECSType = [idComponent]
        let columns: LECSColumns = [LECSId.self]
        let archetypeId: LECSEntityId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            columns: columns,
            size: 1
        )

        let firstEntity: LECSEntityId = entityCounter()

        let rowId = try archetype.insert([LECSId(id: firstEntity)])
        XCTAssertEqual(0, rowId)
        let row = try archetype.read(rowId)!
        let firstEntityId = row[0] as! LECSId
        XCTAssertEqual(firstEntity, firstEntityId.id)
    }
}
