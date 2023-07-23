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
        let archetypeId: LECSArchetypeId = entityCounter()
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

    func testUpdateAComponent() throws {
        let positionComponent = entityCounter()

        let type: LECSType = [positionComponent]
        let columns: LECSColumns = [LECSPosition2dF.self]
        let archetypeId: LECSArchetypeId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            columns: columns,
            size: 1
        )

        let rowId = try archetype.insert([LECSPosition2dF(x: 2, y: 3)])
        XCTAssertEqual(0, rowId)
        try archetype.update(rowId, column: 0, component: LECSPosition2dF(x: 10, y: 4))
        let row = try archetype.read(rowId)!
        let updatedPosition = row[0] as! LECSPosition2dF
        XCTAssertEqual(10, updatedPosition.x)
    }

    func testUpdateTwoComponents() throws {
        let positionComponent = entityCounter()

        let type: LECSType = [positionComponent]
        let columns: LECSColumns = [LECSId.self, LECSName.self, LECSPosition2dF.self]
        let archetypeId: LECSArchetypeId = entityCounter()
        let archetype: LECSArchetypeFixedSize = LECSArchetypeFixedSize(
            id: archetypeId,
            type: type,
            columns: columns,
            size: 1
        )

        let rowId = try archetype.insert([LECSId(id: 14), LECSName(name: "Bella"), LECSPosition2dF(x: 2, y: 3)])
        XCTAssertEqual(0, rowId)
        try archetype.update(rowId, column: 1, component: LECSName(name: "Stella"))
        try archetype.update(rowId, column: 2, component: LECSPosition2dF(x: 10, y: 4))
        let row = try archetype.read(rowId)!
        let updatedName = row[1] as! LECSName
        let updatedPosition = row[2] as! LECSPosition2dF
        XCTAssertEqual("Stella", updatedName.name)
        XCTAssertEqual(10.0, updatedPosition.x)
    }
}

final class IncrementingRowManagerTests: XCTestCase {
    func testIncrement() {
        var manager = IncrementingRowManager()

        XCTAssertEqual(0, manager.emptyRow())
        XCTAssertEqual(1, manager.emptyRow())
        XCTAssertEqual(2, manager.emptyRow())
        XCTAssertEqual(3, manager.emptyRow())
    }

    func testFreeRow() {
        var manager = IncrementingRowManager()

        XCTAssertTrue(manager.freeRow(0))
    }

    func testIterator() {
        var manager = IncrementingRowManager()

        for _ in 0..<3 {
            let _ = manager.emptyRow()
        }

        var rowsIterated = 0

        for _ in manager {
            rowsIterated += 1
        }

        XCTAssertEqual(3, rowsIterated)
    }
}

final class RecyclingRowManagerTests: XCTestCase {
    func testIncrement() {
        var manager = RecyclingRowManager()

        XCTAssertEqual(0, manager.emptyRow())
        XCTAssertEqual(1, manager.emptyRow())
        XCTAssertEqual(2, manager.emptyRow())
        XCTAssertEqual(3, manager.emptyRow())
    }

    func testFreeRow() {
        var manager = RecyclingRowManager()

        XCTAssertEqual(0, manager.emptyRow())
        XCTAssertTrue(manager.freeRow(0))
        XCTAssertEqual(0, manager.emptyRow())
    }

    func testIterator() {
        var manager = RecyclingRowManager()

        for _ in 0..<3 {
            let _ = manager.emptyRow()
        }

        var rowsIterated = 0

        for _ in manager {
            rowsIterated += 1
        }

        XCTAssertEqual(3, rowsIterated)
    }
}
