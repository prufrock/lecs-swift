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

    func testSelectOneComponent() throws {
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

    func testSelectTwoComponents() throws {
        let world = LECSWorldFixedSize()

        let player = try world.createEntity("player")

        var activated = false
        var foundId: UInt = 0
        var foundName: String = ""

        let cloze = { (world: LECSWorld, components: [LECSComponent]) in
            activated = true
            let id = components[0] as! LECSId
            let name = components[1] as! LECSName
            foundId = id.id
            foundName = name.name
        }

        world.select([LECSId.self, LECSName.self], cloze)

        XCTAssertTrue(activated)
        XCTAssertEqual(player, foundId)
        XCTAssertEqual("player", foundName)
    }

    func testProcessOneComponent() throws {
        let world = LECSWorldFixedSize()

        let player = try world.createEntity("player")
        try world.addComponent(player, LECSPosition2d(x: 1, y: 2))

        let system = world.addSystem("simple", selector: [LECSPosition2d.self]) { world, components in
            var position = components.first as! LECSPosition2d
            position.x = position.x + 1

            return [position]
        }

        world.process(system: system)

        let position = try world.getComponent(player, LECSPosition2d.self)!

        XCTAssertEqual(2, position.x)
    }

    func testProcessTwoComponents() throws {
        let world = LECSWorldFixedSize()

        let player = try world.createEntity("player")
        try world.addComponent(player, LECSPosition2d(x: 1, y: 2))

        let enemy = try world.createEntity("enemy")
        try world.addComponent(enemy, LECSPosition2d(x: 5, y: 2))

        let system = world.addSystem("simple", selector: [LECSName.self, LECSPosition2d.self]) { world, components in
            let name = components[0] as! LECSName
            var position = components[1] as! LECSPosition2d
            if (name.name == "player") {
                position.x = position.x + 3
            }

            return [name, position]
        }

        world.process(system: system)

        let position = try world.getComponent(player, LECSPosition2d.self)!

        XCTAssertEqual(4, position.x)
        XCTAssertEqual(2, position.y)
    }
}

struct Velocity: LECSComponent {

}
