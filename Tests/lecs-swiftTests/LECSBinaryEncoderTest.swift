//
//  LECSBinaryEncoderTest.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class LECSBinaryEncoderTest: XCTestCase {

    func testEncodeTwoStructs() throws {
        let encoder = LECSBinaryEncoder(
            MemoryLayout<LECSId>.stride + MemoryLayout<LECSPosition2d>.stride
        )

        let id = LECSId(id: 10)
        let position = LECSPosition2d(x: 5, y: 25)

        try! id.encode(to: encoder)
        try! position.encode(to: encoder)

        // read the id struct from the start of the buffer
        let id2 = encoder.data.withUnsafeBytes {
            $0.load(as: LECSId.self)
        }

        // read the position struct after the id struct from the buffer
        let position2 = encoder.data.withUnsafeBytes {
            $0.load(fromByteOffset: MemoryLayout<LECSId>.stride, as: LECSPosition2d.self)
        }

        XCTAssertEqual(10, id2.id)
        XCTAssertEqual(5, position2.x)
        XCTAssertEqual(25, position2.y)
    }
}
