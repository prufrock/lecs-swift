//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSArchetypeTests: XCTestCase {
    var archetypeCounter: Int = 1
    var components: [Int:LECSComponent.Type] = [
        1: LECSPosition2d.self,
        2: LECSVelocity2d.self
    ]


    override func setUp() {
        archetypeCounter = 1
    }

    func testCreateRow() throws {
        let a = archetype(size: 1, type: [])
        let r = a.createRow()

        XCTAssertEqual(1, a.id.rawValue)
        XCTAssertEqual(0, r.id)
        XCTAssertEqual(a.id, r.archetypeId)
    }

    func testRead() throws {
        let a = archetype(size: 1, type: [LECSComponentId(1)])
        let r = a.insert(row: [LECSPosition2d(x: 2.1, y: 3.2)])

        XCTAssertEqual(1, a.id.rawValue)
        XCTAssertEqual(0, r.id)
        XCTAssertEqual(a.id, r.archetypeId)

        let c = a.read(r)[0] as! LECSPosition2d

        XCTAssertEqual(2.1, c.x)
        XCTAssertEqual(3.2, c.y)
    }

    func testDelete() throws {
        let a = archetype(size: 1, type: [])
        let r = a.createRow()

        a.delete(r)

        var count = 0
        a.forEach { _ in
            count += 1
        }

        XCTAssertEqual(0, count)
    }

    func testUpdateRow() throws {
        let a = archetype(size: 1, type: [LECSComponentId(1)])
        let r = a.insert(row: [LECSPosition2d(x: 2.1, y: 3.2)])

        a.update(rowId: r, row: [LECSPosition2d(x: 3.4, y: 0.2)])

        let c = a.read(r)[0] as! LECSPosition2d

        XCTAssertEqual(3.4, c.x)
        XCTAssertEqual(0.2, c.y)
    }

    func testUpdateRowColumn() throws {
        let a = archetype(size: 1, type: [LECSComponentId(1), LECSComponentId(2)])
        let r = a.insert(row: [
            LECSPosition2d(x: 2.1, y: 3.2),
            LECSVelocity2d(x: 0.3, y: 4.5)
        ])

        a.update(rowId: r, column: LECSArchetypeColumn(col: 1), component: LECSVelocity2d(x: 0.5, y: 1.2))

        let c = a.read(r)[1] as! LECSVelocity2d

        XCTAssertEqual(0.5, c.x)
        XCTAssertEqual(1.2, c.y)
    }

    func testIterator() throws {
        let a = archetype(size: 3, type: [LECSComponentId(1), LECSComponentId(2)])
        let _ = a.insert(row: [
            LECSPosition2d(x: 2.1, y: 3.2),
            LECSVelocity2d(x: 0.4, y: 4.5)
        ])
        let _ = a.insert(row: [
            LECSPosition2d(x: 2.2, y: 3.3),
            LECSVelocity2d(x: 0.5, y: 5.5)
        ])
        let _ = a.insert(row: [
            LECSPosition2d(x: 2.3, y: 3.4),
            LECSVelocity2d(x: 0.6, y: 6.5)
        ])

        var count = 0
        a.forEach { _ in
            count += 1
        }

        XCTAssertEqual(3, count)
    }

    private func archetype(size: Int, type: [LECSComponentId]) -> LECSArchetype {
        let t = LECSSparseArrayTable(
            size: size,
            componentTypes: type.map { components[$0.id]! }
        )

        let id = LECSArchetypeId(id: archetypeCounter)
        archetypeCounter += 1

        return LECSArchetype(
            id: id,
            type: type,
            table: t
        )
    }
}
