//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSFixedComponentChartTests: XCTestCase {
    private let pmName: [LECSName] = [
        LECSName(),
        LECSName("Arada")
    ]

    private let pmPosition: [LECSPosition] = [
        LECSPosition(),
        LECSPosition(x: 2.6, y: 3.8)
    ]

    private let pmVelocity: [LECSVelocity] = [
        LECSVelocity(),
        LECSVelocity(x: 1.8, y: 2.9)
    ]

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

    func testSelectASingleRow() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        _ = chart.addComponentTo(row: row, component: LECSPosition(x: 2.1, y: 4.2))

        var count = 0
        var position: LECSPosition? = nil
        chart.select([LECSPosition.self]) { components, columns in
            count += 1
            position = components[columns[0].col] as? LECSPosition
        }

        XCTAssertEqual(1, count)
        XCTAssertEqual(LECSPosition(x: 2.1, y: 4.2), position)
    }

    func testSelectTwoQueries() throws {
        let chart = LECSFixedComponentChart()
        let firstRow = chart.createRow()

        _ = chart.addComponentTo(row: firstRow, component: pmPosition[1])

        let secondRow = chart.createRow()

        _ = chart.addComponentTo(row: secondRow, component: pmVelocity[1])

        var position: LECSPosition = LECSPosition()
        chart.select([LECSPosition.self]) { components, columns in
            position = components[columns[0].col] as! LECSPosition
        }
        XCTAssertEqual(pmPosition[1], position)

        var velocity: LECSVelocity = LECSVelocity()
        chart.select([LECSVelocity.self]) { components, columns in
            velocity = components[columns[0].col] as! LECSVelocity
        }
        XCTAssertEqual(pmVelocity[1], velocity)
    }

    func testSelectAcrossThreeArchetypes() throws {

        let chart = LECSFixedComponentChart()
        var firstRow = chart.createRow()
        firstRow = chart.addComponentTo(row: firstRow, component: pmPosition[1])

        var secondRow = chart.createRow()
        secondRow = chart.addComponentTo(row: secondRow, component: pmVelocity[1])
        secondRow = chart.addComponentTo(row: secondRow, component: pmPosition[1])

        var thirdRow = chart.createRow()
        thirdRow = chart.addComponentTo(row: thirdRow, component: pmPosition[1])
        thirdRow = chart.addComponentTo(row: thirdRow, component: pmName[1])

        var count = 0
        chart.select([LECSPosition.self]) { components, columns in
            count += 1
        }

        XCTAssertEqual(3, count)
    }

    func testUpdateASingleRow() throws {
        let chart = LECSFixedComponentChart()
        var firstRow = chart.createRow()

        firstRow = chart.addComponentTo(row: firstRow, component: LECSPosition(x: 2.1, y: 4.2))

        chart.update([LECSPosition.self]) { components, columns in
            var position = components[columns[0].col] as! LECSPosition
            position.x = 5.2

            return components.update([(columns[0], position)])
        }

        let position = chart.readComponentFrom(row: firstRow, type: LECSPosition.self)
        XCTAssertEqual(LECSPosition(x: 5.2, y: 4.2), position)
    }
}
