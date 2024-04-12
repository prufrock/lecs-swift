//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSSparseArrayTableTests: XCTestCase {
    func testCreate() throws {
        let t = LECSSparseArrayTable(
            size: 1,
            componentTypes: []
        )

        let r = t.create()

        XCTAssertEqual(0, r)
        XCTAssertEqual(1, t.count)
    }

    func testInsert() throws {
        let t = LECSSparseArrayTable(
            size: 1,
            componentTypes: [LECSPosition2d.self]
        )

        let r = t.insert([LECSPosition2d(x: 3.0, y: -2.0)])

        XCTAssertEqual(0, r)
        XCTAssertEqual(1, t.count)

        let position = t.read(r)[0] as! LECSPosition2d

        XCTAssertEqual(3.0, position.x)
        XCTAssertEqual(-2.0, position.y)
    }

    func testDelete() throws {
        let t = LECSSparseArrayTable(
            size: 1,
            componentTypes: [LECSPosition2d.self]
        )

        let r = t.insert([LECSPosition2d(x: 3.0, y: -2.0)])

        XCTAssertEqual(0, r)
        XCTAssertEqual(1, t.count)

        t.delete(r)
        XCTAssertEqual(0, t.count)

        let n = t.insert([LECSPosition2d(x: 4.0, y: -3.7)])

        XCTAssertEqual(0, n)
        XCTAssertEqual(1, t.count)

        let position = t.read(n)[0] as! LECSPosition2d

        XCTAssertEqual(4.0, position.x)
        XCTAssertEqual(-3.7, position.y)
    }

    func testIterator() throws {
        let t = LECSSparseArrayTable(
            size: 3,
            componentTypes: [LECSPosition2d.self]
        )

        _ = t.insert([LECSPosition2d(x: 1.2, y: -2.0)])
        let r = t.insert([LECSPosition2d(x: 2.6, y: -6.3)])
        _ = t.insert([LECSPosition2d(x: 7.1, y: -5.1)])

        t.delete(r)

        var count: Int = 0
        t.forEach { _ in
            count += 1
        }

        XCTAssertEqual(2, count)
    }

    func testUpdateRowColumnComponent() throws {
        let t = LECSSparseArrayTable(
            size: 1,
            componentTypes: [LECSPosition2d.self, LECSVelocity2d.self]
        )

        let r = t.insert([
            LECSPosition2d(x: 2.6, y: -6.3),
            LECSVelocity2d(x: 4.8, y: 1.2)
        ])

        _ = t.update(row: r, column: 1, component: LECSVelocity2d(x: 2.2, y: 3.7))

        let components = t.read(r)

        let velocity = components[1] as! LECSVelocity2d

        XCTAssertEqual(2.2, velocity.x)
        XCTAssertEqual(3.7, velocity.y)
    }

    func testUpdateRowComponents() throws {
        let t = LECSSparseArrayTable(
            size: 1,
            componentTypes: [LECSPosition2d.self, LECSVelocity2d.self]
        )

        let r = t.insert([
            LECSPosition2d(x: 2.6, y: -6.3),
            LECSVelocity2d(x: 4.8, y: 1.2)
        ])

        _ = t.update(row: r, components: [LECSPosition2d(x: 4.2, y: 7.8), LECSVelocity2d(x: 2.2, y: 3.7)])

        let components = t.read(r)

        let position = components[0] as! LECSPosition2d
        let velocity = components[1] as! LECSVelocity2d

        XCTAssertEqual(4.2, position.x)
        XCTAssertEqual(7.8, position.y)
        XCTAssertEqual(2.2, velocity.x)
        XCTAssertEqual(3.7, velocity.y)
    }
}
