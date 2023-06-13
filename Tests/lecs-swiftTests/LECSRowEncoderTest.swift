//
//  LECSBinaryEncoderTest.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class LECSRowEncoderTest: XCTestCase {

    func testEncodeOneStruct() throws {
        let size = 1
        let encoder = LECSRowEncoder(MemoryLayout<LECSId>.stride * size)
        let entity: [LECSComponent] = [LECSId(id: 56)]

        let data = try encoder.encode(entity)

        XCTAssertEqual(56, data[0])
    }

    func testEncodeTwoStructs() throws {
        let size = 1
        let stride = MemoryLayout<LECSId>.stride + MemoryLayout<LECSName>.stride
        let encoder = LECSRowEncoder(stride * size)
        let entity: [LECSComponent] = [LECSId(id: 24), LECSName(name: "Bella")]

        let data = try encoder.encode(entity)

        // read the id struct from the start of the buffer
        let id = data.withUnsafeBytes {
            $0.load(as: LECSId.self)
        }

        // read the name struct after the id struct from the buffer
        let name = data.withUnsafeBytes {
            $0.load(fromByteOffset: MemoryLayout<LECSId>.stride, as: LECSName.self)
        }

        XCTAssertEqual(24, id.id)
        XCTAssertEqual("Bella", name.name)
    }
}
