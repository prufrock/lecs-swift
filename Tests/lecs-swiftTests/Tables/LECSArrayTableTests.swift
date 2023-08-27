//
//  LECSArrayTableTests.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class LECSArrayTableTests: XCTestCase {

    func testAddAComponentToATable() throws {
        var table = LECSArrayTable(
            size: 1,
            columnTypes: [LECSId.self]
        )

        let id = LECSId(id: 1)
        let entity: [LECSComponent] = [id]
        let rowId = try table.insert(entity)
        XCTAssertEqual(0, rowId)
        XCTAssertEqual(1, table.count)

        let first = try table.read(0)!
        XCTAssertEqual(1, (first[0] as! LECSId).id)
    }

    func testAddManyComponentsToATable() throws {
        var table = LECSArrayTable(
            size: 5,
            columnTypes: [LECSId.self]
        )

        // insert 5 LECSIds into the table
        for i in 1...5 {
            let id = LECSId(id: UInt(i))
            let entity: [LECSComponent] = [id]
            let rowId = try table.insert(entity)
            XCTAssertEqual(i - 1, rowId)
        }
        XCTAssertEqual(5, table.count)

        // read the 5 LECIds out of the table
        for i in 0..<5 {
            let row = try table.read(i)!
            let id = row[0] as! LECSId
            XCTAssertEqual(UInt(i + 1), id.id)
        }
    }

    func testPerformanceOfUpdate() throws {
        let size = 10000
        var table = LECSArrayTable(
            size: size,
            columnTypes: [LECSId.self]
        )

        // insert 5 LECSIds into the table
        for i in 1...size {
            let id = LECSId(id: UInt(i))
            let entity: [LECSComponent] = [id]
            let rowId = try table.insert(entity)
            XCTAssertEqual(i - 1, rowId)
        }
        XCTAssertEqual(size, table.count)

        self.measure {
            for i in 0..<size {
                try! table.update(i, column: 0, component: LECSId(id: UInt(i)))
                let row = try! table.read(i)!
                let id = row[0] as! LECSId
                XCTAssertEqual(UInt(i), id.id)
            }
        }
    }
}
