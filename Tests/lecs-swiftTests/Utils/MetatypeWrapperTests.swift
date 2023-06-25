//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class MetatypeWrapperTests: XCTestCase {
    func testHashingIntoADictionary() throws {
        var dict: [MetatypeWrapper: String] = [:]
        dict[String.self] = "String"
        dict[Int.self] = "Int"

        XCTAssertEqual(dict[String.self]!, "String")
        XCTAssertEqual(dict[Int.self]!, "Int")
    }

    func testHashingIntoASet() throws {
        var set: Set<MetatypeWrapper> = Set()
        let result = set.insert(String.self)

        XCTAssertEqual(true, result.inserted)
        XCTAssertEqual(MetatypeWrapper(String.self), result.memberAfterInsert)
        XCTAssertEqual(true, set.contains(String.self))
    }
}
