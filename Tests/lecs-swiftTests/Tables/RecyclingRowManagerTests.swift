//
//  LECSBufferTableTests.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import XCTest
@testable import lecs_swift

final class RecyclingRowManagerTests: XCTestCase {
    func testIncrement() {
        var manager = RecyclingRowManager()

        XCTAssertEqual(0, manager.emptyRow())
        XCTAssertEqual(1, manager.emptyRow())
        XCTAssertEqual(2, manager.emptyRow())
        XCTAssertEqual(3, manager.emptyRow())
    }

    func testFreeRow() {
        var manager = RecyclingRowManager()

        XCTAssertEqual(0, manager.emptyRow())
        XCTAssertTrue(manager.freeRow(0))
        XCTAssertEqual(0, manager.emptyRow())
    }

    func testIterator() {
        var manager = RecyclingRowManager()

        for _ in 0..<3 {
            let _ = manager.emptyRow()
        }

        var rowsIterated = 0

        for _ in manager {
            rowsIterated += 1
        }

        XCTAssertEqual(3, rowsIterated)
    }
}
