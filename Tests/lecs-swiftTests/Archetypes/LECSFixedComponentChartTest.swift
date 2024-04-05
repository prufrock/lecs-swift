//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSFixedComponentChartTests: XCTestCase {
    func testCreateRow() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        XCTAssertEqual(0, row.id)
    }

    func testAddComponent() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let newRow = chart.addComponentTo(row: row, component: LECSPosition(x: 1.2, y: 3.4))

        XCTAssertNotEqual(row.archetypeId, newRow.archetypeId)

        let updatedRow = chart.addComponentTo(row: newRow, component: LECSPosition(x: 2.5, y: 7.9))

        XCTAssertEqual(newRow, updatedRow)
    }

    func testRemoveComponent() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let positionRow = chart.addComponentTo(row: row, component: LECSPosition(x: 2.8, y: 4.1))

        XCTAssertNotEqual(row.archetypeId, positionRow.archetypeId)

        let positionVelocityRow = chart.addComponentTo(row: positionRow, component: LECSVelocity(x: 1.2, y: 3.4))

        let removeVelocityRow = chart.removeComponentFrom(row: positionVelocityRow, type: LECSVelocity.self)

        XCTAssertEqual(positionRow.archetypeId, removeVelocityRow.archetypeId)
    }

    func testReadComponentFrom() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let positionRow = chart.addComponentTo(row: row, component: LECSPosition(x: 2.8, y: 4.1))
        let positionVelocityRow = chart.addComponentTo(row: positionRow, component: LECSVelocity(x: 1.2, y: 3.4))

        let position = chart.readComponentFrom(row: positionVelocityRow, type: LECSPosition.self)

        XCTAssertEqual(2.8, position.x)
        XCTAssertEqual(4.1, position.y)

        let velocity = chart.readComponentFrom(row: positionVelocityRow, type: LECSVelocity.self)

        XCTAssertEqual(1.2, velocity.x)
        XCTAssertEqual(3.4, velocity.y)
    }

    func testDelete() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        chart.delete(row: row)

        let rowAfterDelete = chart.createRow()

        XCTAssertEqual(row, rowAfterDelete)
    }
}
