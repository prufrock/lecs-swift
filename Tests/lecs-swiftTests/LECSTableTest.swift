//
//  LECSBinaryEncoderTest.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class LECSTableTest: XCTestCase {

    func testAddAComponentToATable() throws {
        var table = LECSTable(
            elementSize: MemoryLayout<LECSId>.stride,
            size: 1
        )

        let encoder = LECSRowEncoder(MemoryLayout<LECSId>.stride)
        let id = LECSId(id: 1)
        let entity: [LECSComponent] = [id]
        let data = try encoder.encode(entity)
        table.add(data)
        XCTAssertEqual(1, table.count)

        let first = table.read(0)
        XCTAssertEqual(1, first[0])
    }

    func testAddManyComponentsToATable() throws {
        var table = LECSTable(
            elementSize: MemoryLayout<LECSId>.stride,
            size: 5
        )

        // insert 5 LECSIds into the table
        for i in 1...5 {
            let encoder = LECSRowEncoder(MemoryLayout<LECSId>.stride)
            let id = LECSId(id: UInt(i))
            let entity: [LECSComponent] = [id]
            let data = try encoder.encode(entity)
            table.add(data)
        }
        XCTAssertEqual(5, table.count)

        // read the 5 LECIds out of the table
        for i in 0..<5 {
        	let first = table.read(i)
            let decoder = LECSRowDecoder(first)
            let values = try decoder.decode(types: [LECSId.self])
            let id = values[0] as! LECSId
            XCTAssertEqual(UInt(i + 1), id.id)
        }
    }
}
