//
//  LECSBinaryEncoderTest.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class LECSRowDecoderTests: XCTestCase {

    func testDecodeOneStruct() throws {
        let size = 1
        let encoder = LECSRowEncoder(MemoryLayout<LECSId>.stride * size)
        let entity: [LECSComponent] = [LECSId(id: 56)]

        let data = try encoder.encode(entity)

        let decoder = LECSRowDecoder(data)
        let result = try decoder.decode(types: [LECSId.self])

        // assert the first element is and instance of LECSId
        XCTAssertTrue(result[0] is LECSId)
        XCTAssertEqual(56, data[0])
    }

    func testDecodeVelocity2d() throws {
        let size = 1
        let encoder = LECSRowEncoder(MemoryLayout<LECSVelocity2d>.stride * size)
        let entity: [LECSComponent] = [LECSVelocity2d(x: 2.1, y: 3.0)]

        let data = try encoder.encode(entity)

        let decoder = LECSRowDecoder(data)
        let result = try decoder.decode(types: [LECSVelocity2d.self])

        // assert the first element is and instance of LECSId
        XCTAssertTrue(result[0] is LECSVelocity2d)
        XCTAssertEqual(2.1, (result[0] as! LECSVelocity2d).velocity.x)
    }

    func testDecodeTwoStructs() throws {
        let size = 1
        let stride = MemoryLayout<LECSId>.stride + MemoryLayout<LECSName>.stride
        let encoder = LECSRowEncoder(stride * size)
        let entity: [LECSComponent] = [LECSId(id: 24), LECSName(name: "Bella")]

        let data = try encoder.encode(entity)

        let type: [LECSComponent.Type] = [LECSId.self, LECSName.self]
        let decoder = LECSRowDecoder(data)
        let result = try decoder.decode(types: type)

        let id = result[0] as! LECSId
        let name = result[1] as! LECSName

        XCTAssertEqual(24, id.id)
        XCTAssertEqual("Bella", name.name)
    }
}
