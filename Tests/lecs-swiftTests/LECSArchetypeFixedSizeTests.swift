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
        let archetypeId: LECSArchetypeId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            size: 1
        )

        let firstEntity: LECSEntityId = entityCounter()

        let rowId = archetype.insert([LECSId(id: firstEntity)])
        XCTAssertEqual(0, rowId)
        let row = archetype.read(rowId)!
        let firstEntityId = row[0] as! LECSId
        XCTAssertEqual(firstEntity, firstEntityId.id)
    }

    func testUpdateAComponent() throws {
        let positionComponent = entityCounter()

        let type: LECSType = [positionComponent]
        let archetypeId: LECSArchetypeId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            size: 1
        )

        let rowId = archetype.insert([LECSPosition2d(x: 2, y: 3)])
        XCTAssertEqual(0, rowId)
        archetype.update(rowId, column: 0, component: LECSPosition2d(x: 10, y: 4))
        let row = archetype.read(rowId)!
        let updatedPosition = row[0] as! LECSPosition2d
        XCTAssertEqual(10, updatedPosition.x)
    }

    func testUpdateTwoComponents() throws {
        let positionComponent = entityCounter()

        let type: LECSType = [positionComponent]
        let archetypeId: LECSArchetypeId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            size: 1
        )

        let rowId = archetype.insert(
            [LECSId(id: 14), LECSName(name: "Bella"), LECSPosition2d(x: 2, y: 3)]
        )
        XCTAssertEqual(0, rowId)
        
        archetype.update(rowId, column: 1, component: LECSName(name: "Stella"))
        archetype.update(rowId, column: 2, component: LECSPosition2d(x: 10, y: 4))
        let row = archetype.read(rowId)!
        let updatedName = row[1] as! LECSName
        let updatedPosition = row[2] as! LECSPosition2d
        XCTAssertEqual("Stella", updatedName.name)
        XCTAssertEqual(10.0, updatedPosition.x)
    }
}
