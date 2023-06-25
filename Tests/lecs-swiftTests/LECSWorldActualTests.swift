//
//  LECSWorldActualTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSWorldActualTests: XCTestCase {
    func testCreateEntities() throws {
        let world = LECSWorldActual()

        let player = try world.createEntity("player")

        XCTAssertLessThanOrEqual(0, player, "Create an entity, get an Id.")
        XCTAssertTrue(world.hasComponent(player, component: LECSId.self))
        XCTAssertTrue(world.hasComponent(player, component: LECSName.self))
        XCTAssertFalse(world.hasComponent(player, component: Velocity.self))
        let playerName = try world.getComponent(player, LECSName.self)
        XCTAssertEqual("player", playerName?.name)

        let enemy = try world.createEntity("enemy")

        XCTAssertLessThanOrEqual(0, enemy, "Create another entity, get another Id. The Id may not necessarily occur after the player, in case reuse needs to happen.")
        XCTAssertNotEqual(player, enemy, "The Ids of player and enemy should not be equal.")
    }
}

struct Velocity: LECSComponent {

}
