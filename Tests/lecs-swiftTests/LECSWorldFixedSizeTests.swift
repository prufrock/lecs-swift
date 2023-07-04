//
//  LECSWorldFixedSizeTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSWorldFixedSizeTests: XCTestCase {
    func testCreateEntities() throws {
        let world = LECSWorldFixedSize()

        let player = try world.createEntity("player")

        XCTAssertLessThanOrEqual(0, player, "Create an entity, get an Id.")
        XCTAssertTrue(world.hasComponent(player, LECSId.self))
        XCTAssertTrue(world.hasComponent(player, LECSName.self))
        XCTAssertFalse(world.hasComponent(player, Velocity.self))
        let playerId = try world.getComponent(player, LECSId.self)
        let playerName = try world.getComponent(player, LECSName.self)
        XCTAssertEqual(player, playerId?.id)
        XCTAssertEqual("player", playerName?.name)

        let enemy = try world.createEntity("enemy")

        XCTAssertLessThanOrEqual(0, enemy, "Create another entity, get another Id. The Id may not necessarily occur after the player, in case reuse needs to happen.")
        XCTAssertNotEqual(player, enemy, "The ids of player and enemy should not be equal.")

        let enemyId = try world.getComponent(enemy, LECSId.self)
        let enemyName = try world.getComponent(enemy, LECSName.self)
        XCTAssertEqual(enemy, enemyId?.id)
        XCTAssertEqual("enemy", enemyName?.name)
    }

    func testSelect() throws {
        let world = LECSWorldFixedSize()

        let player = try world.createEntity("player")

        var activated = false
        var foundId: UInt = 0

        let cloze = { (world: LECSWorld, components: [LECSComponent]) in
            activated = true
            let id = components[0] as! LECSId
            foundId = id.id
        }

        world.select([LECSId.self], cloze)

        XCTAssertTrue(activated)
        XCTAssertEqual(player, foundId)
    }
}

struct Velocity: LECSComponent {

}
