//
//  LECSArchetypeManagerTests.swift
//  
//
//  Created by David Kanenwisher on 8/17/23.
//

import XCTest
@testable import lecs_swift

final class LECSArchetypeManagerTests: XCTestCase {
    func testEmptyArchetype() throws {
        let manager = LECSArchetypeManager()
        XCTAssertEqual(1, manager.emptyArchetype.id)
    }

    func testNearestArchetypeWhenItsAnAddEdge() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype

        let addArchetype = manager.createArchetype(
            columns: [LECSId.self],
            type: [1]
        )

        startingArchetype.setAddEdge(1, addArchetype)

        let newArchetype = manager.nearestArchetype(to: startingArchetype, with: 1, component: LECSId.self)

        XCTAssertEqual(addArchetype.id, newArchetype.id)
    }

    func testNearestArchetypeWhenItDoesNotExistYet() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype


        let newArchetype = manager.nearestArchetype(to: startingArchetype, with: 1, component: LECSId.self)

        XCTAssertNotEqual(startingArchetype.id, newArchetype.id)
    }

    func testNearestArchetypeWhenThePathIsThroughAPreviousArchetype() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype


        let idArchetype = manager.nearestArchetype(to: startingArchetype, with: 1, component: LECSId.self)
        let idNameArchetype = manager.nearestArchetype(to: idArchetype, with: 2, component: LECSName.self)

        let idNamePosition = manager.nearestArchetype(to: idNameArchetype, with: 3, component: LECSPosition2d.self)
        let idNamePositionVelocity = manager.nearestArchetype(to: idNamePosition, with: 4, component: LECSVelocity2d.self)

        let idNameVelocity = manager.nearestArchetype(to: idNameArchetype, with: 4, component: LECSVelocity2d.self)
        let idNameVelocityPosition = manager.nearestArchetype(to: idNameVelocity, with: 3, component: LECSPosition2d.self)

        XCTAssertEqual(idNamePositionVelocity.id, idNameVelocityPosition.id)
    }
}
