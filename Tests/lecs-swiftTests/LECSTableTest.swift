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

        let encoder = LECSBinaryEncoder(MemoryLayout<LECSId>.stride)
        let id = LECSId(id: 1)
        try id.encode(to: encoder)
        table.add(encoder.data)
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
            let encoder = LECSBinaryEncoder(MemoryLayout<LECSId>.stride)
            let id = LECSId(id: UInt(i))
            try id.encode(to: encoder)
            table.add(encoder.data)
        }
        XCTAssertEqual(5, table.count)


        for i in 0..<5 {
        	let first = table.read(i)
            //TODO: Need to create LECSBinaryDecoder
            let firstId: LECSId = LECSBinaryEncoder(from: first).data.withUnsafeBytes {
                $0.load(as: LECSId.self)
            }
            XCTAssertEqual(UInt(i + 1), firstId.id)
        }
    }
}
