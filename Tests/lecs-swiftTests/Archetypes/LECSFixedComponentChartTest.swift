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

    private let pmPosition: [LECSPosition2d] = [
        LECSPosition2d(),
        LECSPosition2d(x: 2.6, y: 3.8)
    ]

    private let pmVelocity: [LECSVelocity2d] = [
        LECSVelocity2d(),
        LECSVelocity2d(x: 1.8, y: 2.9)
    ]

    func testCreateRow() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        XCTAssertEqual(0, row.id)
    }

    func testAddComponent() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let newRow = chart.addComponentTo(row: row, component: LECSPosition2d(x: 1.2, y: 3.4))

        XCTAssertNotEqual(row.archetypeId, newRow.archetypeId)

        let updatedRow = chart.addComponentTo(row: newRow, component: LECSPosition2d(x: 2.5, y: 7.9))

        XCTAssertEqual(newRow, updatedRow)
    }

    func testRemoveComponent() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let positionRow = chart.addComponentTo(row: row, component: LECSPosition2d(x: 2.8, y: 4.1))

        XCTAssertNotEqual(row.archetypeId, positionRow.archetypeId)

        let positionVelocityRow = chart.addComponentTo(row: positionRow, component: LECSVelocity2d(x: 1.2, y: 3.4))

        let removeVelocityRow = chart.removeComponentFrom(row: positionVelocityRow, type: LECSVelocity2d.self)

        XCTAssertEqual(positionRow.archetypeId, removeVelocityRow.archetypeId)
    }

    func testReadComponentFrom() throws {
        let chart = LECSFixedComponentChart()
        let row = chart.createRow()

        let positionRow = chart.addComponentTo(row: row, component: LECSPosition2d(x: 2.8, y: 4.1))
        let positionVelocityRow = chart.addComponentTo(row: positionRow, component: LECSVelocity2d(x: 1.2, y: 3.4))

        let position = chart.readComponentFrom(row: positionVelocityRow, type: LECSPosition2d.self)

        XCTAssertEqual(2.8, position.x)
        XCTAssertEqual(4.1, position.y)

        let velocity = chart.readComponentFrom(row: positionVelocityRow, type: LECSVelocity2d.self)

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

        _ = chart.addComponentTo(row: row, component: LECSPosition2d(x: 2.1, y: 4.2))

        var count = 0
        var position: LECSPosition2d? = nil
        chart.select([LECSPosition2d.self]) { components, columns in
            count += 1
            position = components[columns[0].col] as? LECSPosition2d
        }

        XCTAssertEqual(1, count)
        XCTAssertEqual(LECSPosition2d(x: 2.1, y: 4.2), position)
    }

    func testSelectTwoQueries() throws {
        let chart = LECSFixedComponentChart()
        let firstRow = chart.createRow()

        _ = chart.addComponentTo(row: firstRow, component: pmPosition[1])

        let secondRow = chart.createRow()

        _ = chart.addComponentTo(row: secondRow, component: pmVelocity[1])

        var position: LECSPosition2d = LECSPosition2d()
        chart.select([LECSPosition2d.self]) { components, columns in
            position = components[columns[0].col] as! LECSPosition2d
        }
        XCTAssertEqual(pmPosition[1], position)

        var velocity: LECSVelocity2d = LECSVelocity2d()
        chart.select([LECSVelocity2d.self]) { components, columns in
            velocity = components[columns[0].col] as! LECSVelocity2d
        }
        XCTAssertEqual(pmVelocity[1], velocity)
    }

    func testSelectAfterDeleting() throws {
        let chart = LECSFixedComponentChart()
        var firstRow = chart.createRow()
        firstRow = chart.addComponentTo(row: firstRow, component: pmPosition[1])

        var secondRow = chart.createRow()
        secondRow = chart.addComponentTo(row: secondRow, component: pmPosition[1])

        var thirdRow = chart.createRow()
        thirdRow = chart.addComponentTo(row: thirdRow, component: pmPosition[1])

        chart.delete(row: firstRow)
        chart.delete(row: secondRow)

        var count = 0
        chart.select([LECSPosition2d.self]) { components, columns in
            count += 1
        }

        XCTAssertEqual(1, count)
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
        chart.select([LECSPosition2d.self]) { components, columns in
            count += 1
        }

        XCTAssertEqual(3, count)
    }

    func testUpdateASingleRow() throws {
        let chart = LECSFixedComponentChart()
        var firstRow = chart.createRow()

        firstRow = chart.addComponentTo(row: firstRow, component: LECSPosition2d(x: 2.1, y: 4.2))

        chart.update([LECSPosition2d.self]) { components, columns in
            var position = components.component(at: 0, columns, LECSPosition2d.self)
            position.x = 5.2

            return components.update([(columns[0], position)])
        }

        let position = chart.readComponentFrom(row: firstRow, type: LECSPosition2d.self)
        XCTAssertEqual(LECSPosition2d(x: 5.2, y: 4.2), position)
    }
}
