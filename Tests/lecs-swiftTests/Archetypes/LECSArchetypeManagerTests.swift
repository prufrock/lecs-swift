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
        let idComponent: LECSComponentId = 1

        let addArchetype = manager.createArchetype(
            type: [idComponent]
        )

        startingArchetype.setAddEdge(idComponent, addArchetype)

        let newArchetype = manager.nearestArchetype(to: startingArchetype, with: idComponent)

        XCTAssertEqual(addArchetype.id, newArchetype.id)
    }

    func testNearestArchetypeWhenItDoesNotExistYet() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype
        let idComponent: LECSComponentId = 1

        let newArchetype = manager.nearestArchetype(to: startingArchetype, with: idComponent)

        XCTAssertNotEqual(startingArchetype.id, newArchetype.id)
    }

    func testNearestArchetypeWhenThePathIsThroughAPreviousArchetype() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype
        let idComponent: LECSComponentId = 1
        let nameComponent: LECSComponentId = 2
        let positionComponent: LECSComponentId = 3
        let velocityComponent: LECSComponentId = 4


        let idArchetype = manager.nearestArchetype(to: startingArchetype, with: idComponent)
        let idNameArchetype = manager.nearestArchetype(to: idArchetype, with: nameComponent)

        let idNamePosition = manager.nearestArchetype(to: idNameArchetype, with: positionComponent)
        let idNamePositionVelocity = manager.nearestArchetype(to: idNamePosition, with: velocityComponent)

        let idNameVelocity = manager.nearestArchetype(to: idNameArchetype, with: velocityComponent)
        let idNameVelocityPosition = manager.nearestArchetype(to: idNameVelocity, with: positionComponent)

        XCTAssertEqual(idNamePositionVelocity.id, idNameVelocityPosition.id)
    }

    func testRemoveAComponent() throws {
        var manager = LECSArchetypeManager()
        let startingArchetype = manager.emptyArchetype
        let idComponent: LECSComponentId = 1
        let nameComponent: LECSComponentId = 2
        let positionComponent: LECSComponentId = 3

        let idArchetype = manager.nearestArchetype(to: startingArchetype, with: idComponent)
        let idNameArchetype = manager.nearestArchetype(to: idArchetype, with: nameComponent)
        let idNamePositionArchetype = manager.nearestArchetype(to: idNameArchetype, with: positionComponent)
        let idPositionArchetype = manager.nearestArchetype(to: idArchetype, with: positionComponent)

        let rowId = idNamePositionArchetype.insert(
            [LECSId(id: 1), LECSName(name: "Catherine"), LECSPosition2d(x: 2.0, y: 3.1)]
        )

        let record = LECSRecord(entityId: 1, archetype: idNamePositionArchetype, row: rowId)

        let alteredRecord = try manager.removeComponent(from: record, componentId: nameComponent)

        XCTAssertEqual(idPositionArchetype.id, alteredRecord.archetype.id)
    }
}
