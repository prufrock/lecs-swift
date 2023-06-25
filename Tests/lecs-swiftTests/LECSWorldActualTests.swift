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

        let player = world.createEntity("player")

        XCTAssertLessThanOrEqual(0, player, "Create an entity, get an Id.")

        let enemy = world.createEntity("enemy")

        XCTAssertLessThanOrEqual(0, enemy, "Create another entity, get another Id. The Id may not necessarily occur after the player, in case reuse needs to happen.")
        XCTAssertNotEqual(player, enemy, "The Ids of player and enemy should not be equal.")
    }
}
