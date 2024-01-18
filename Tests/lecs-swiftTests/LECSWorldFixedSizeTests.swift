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
        let world = createWorld()

        let player = world.createEntity("player")

        XCTAssertLessThanOrEqual(0, player, "Create an entity, get an Id.")
        XCTAssertTrue(world.hasComponent(player, LECSId.self))
        XCTAssertTrue(world.hasComponent(player, LECSName.self))
        XCTAssertFalse(world.hasComponent(player, Velocity.self))
        let playerId = world.getComponent(player, LECSId.self)
        let playerName = world.getComponent(player, LECSName.self)
        XCTAssertEqual(player, playerId?.id)
        XCTAssertEqual("player", playerName?.name)
        XCTAssertEqual(player, world.entity(named: LECSName(name: "player")))

        let enemy = world.createEntity("enemy")

        XCTAssertLessThanOrEqual(0, enemy, "Create another entity, get another Id. The Id may not necessarily occur after the player, in case reuse needs to happen.")
        XCTAssertNotEqual(player, enemy, "The ids of player and enemy should not be equal.")

        let enemyId = world.getComponent(enemy, LECSId.self)
        let enemyName = world.getComponent(enemy, LECSName.self)
        XCTAssertEqual(enemy, enemyId?.id)
        XCTAssertEqual("enemy", enemyName?.name)
    }

    func testSelectOneComponent() throws {
        let world = createWorld()

        let player = world.createEntity("player")

        var activated = false
        var foundId: UInt = 0

        let cloze = { (world: LECSWorld, row: LECSRow, columns: LECSColumns) in
            activated = true
            let id = row.component(at: 0, columns, LECSId.self)
            foundId = id.id
        }

        world.select([LECSId.self], cloze)

        XCTAssertTrue(activated)
        XCTAssertEqual(player, foundId)
    }

    func testSelectTwoComponents() throws {
        let world = createWorld()

        let player = world.createEntity("player")

        var activated = false
        var foundId: UInt = 0
        var foundName: String = ""

        let cloze = { (world: LECSWorld, row: LECSRow, columns: LECSColumns) in
            activated = true
            let id = row.component(at: 0, columns, LECSId.self)
            let name = row.component(at: 1, columns, LECSName.self)
            foundId = id.id
            foundName = name.name
        }

        world.select([LECSId.self, LECSName.self], cloze)

        XCTAssertTrue(activated)
        XCTAssertEqual(player, foundId)
        XCTAssertEqual("player", foundName)
    }

    func testSelectTwoComponentsAfterAddingThemInADifferentOrder() throws {
        let world = createWorld()

        let player = world.createEntity("player")
        let enemy = world.createEntity("enemy")

        world.addComponent(player, LECSPosition2d(x: 0.1, y: 0.5))
        world.addComponent(player, LECSVelocity2d(x: 0.3, y: 0.8))

        world.addComponent(enemy, LECSVelocity2d(x: 0.2, y: 0.4))
        world.addComponent(enemy, LECSPosition2d(x: 1.0, y: 2.0))

        var activated = false
        var foundPositionX: [Float] = []
        var foundVelocityX: [Float] = []

        let cloze = { (world: LECSWorld, row: LECSRow, columns: LECSColumns) in
            activated = true
            let position = row.component(at: 0, columns, LECSPosition2d.self)
            let velocity = row.component(at: 1, columns, LECSVelocity2d.self)
            foundPositionX.append(position.x)
            foundVelocityX.append(velocity.velocity.x)
        }

        world.select([LECSPosition2d.self, LECSVelocity2d.self], cloze)

        XCTAssertTrue(activated)
        XCTAssertEqual(0.1, foundPositionX[0])
        XCTAssertEqual(0.3, foundVelocityX[0])
        XCTAssertEqual(1.0, foundPositionX[1])
        XCTAssertEqual(0.2, foundVelocityX[1])
    }

    func testProcessOneComponent() throws {
        let world = createWorld()

        let player = world.createEntity("player")
        world.addComponent(player, LECSPosition2d(x: 1, y: 2))

        let system = world.addSystem("simple", selector: [LECSPosition2d.self]) { world, row, columns in
            var position = row.component(at: 0, columns, LECSPosition2d.self)
            position.x = position.x + 1

            return [position]
        }

        world.process(system: system)

        let position = world.getComponent(player, LECSPosition2d.self)!

        XCTAssertEqual(2, position.x)
    }

    func testProcessTwoComponents() throws {
        let world = createWorld()

        let player = world.createEntity("player")
        world.addComponent(player, LECSPosition2d(x: 1, y: 2))

        let enemy = world.createEntity("enemy")
        world.addComponent(enemy, LECSPosition2d(x: 5, y: 2))

        let system = world.addSystem("simple", selector: [LECSName.self, LECSPosition2d.self]) { world, row, columns in
            let name = row.component(at: 0, columns, LECSName.self)
            var position = row.component(at: 1, columns, LECSPosition2d.self)
            if (name.name == "player") {
                position.x = position.x + 3
            }

            return [name, position]
        }

        world.process(system: system)

        let position = world.getComponent(player, LECSPosition2d.self)!

        XCTAssertEqual(4, position.x)
        XCTAssertEqual(2, position.y)
    }

    func testProcessTwoComponentsWithFloat() throws {
        let world = createWorld()

        let player = world.createEntity("player")
        world.addComponent(player, LECSPosition2d(x: 1.0, y: 2.0))

        let enemy = world.createEntity("enemy")
        world.addComponent(enemy, LECSPosition2d(x: 5.0, y: 2.0))

        let system = world.addSystem("simple", selector: [LECSName.self, LECSPosition2d.self]) { world, row, columns in
            let name = row.component(at: 0, columns, LECSName.self)
            var position = row.component(at: 1, columns, LECSPosition2d.self)
            if (name.name == "player") {
                position.x = position.x + 3.2
            }

            return [name, position]
        }

        world.process(system: system)

        let position = world.getComponent(player, LECSPosition2d.self)!

        XCTAssertEqual(4.2, position.x)
        XCTAssertEqual(2, position.y)
    }


    /// I ran into this problem where it seems like I am "OR"ing the components in the query when I mean it to be an "AND".
    /// This test ensures they stay as an "AND".
    func testProcessTwoComponentsWithOverlappingArchetypes() throws {
        let world = createWorld()

        let player = world.createEntity("player")
        world.addComponent(player, LECSPosition2d(x: 1.0, y: 2.0))
        world.addComponent(player, LECSVelocity2d(x: 2.0, y: 1.0))

        let enemy = world.createEntity("enemy")
        world.addComponent(enemy, LECSPosition2d(x: 5.0, y: 2.0))

        var processed = 0
        let system = world.addSystem("simple", selector: [LECSPosition2d.self, LECSVelocity2d.self]) { world, row, columns in
            let name = row.component(at: 0, columns, LECSPosition2d.self)
            let position = row.component(at: 1, columns, LECSVelocity2d.self)

            processed += 1

            return [name, position]
        }

        world.process(system: system)


        XCTAssertEqual(1, processed)
    }

    func testUpdateAComponent() throws {
        let world = createWorld()

        let e1 = world.createEntity("e1")

        world.addComponent(e1, LECSPosition2d(x: 4, y: 3))

        XCTAssertEqual(4.0, world.getComponent(e1, LECSPosition2d.self)!.x)

        world.addComponent(e1, LECSPosition2d(x: 5, y: 3))

        XCTAssertEqual(5.0, world.getComponent(e1, LECSPosition2d.self)!.x)
    }

    func testASystemOnlyProcessesNotDeletedEntities() throws {
        let world = createWorld()

        let _ = world.createEntity("e1")
        let e2 = world.createEntity("e2")
        let _ = world.createEntity("e3")

        var ids:[LECSId] = []
        let system = world.addSystem("ids", selector: [LECSId.self, LECSName.self]) { world, row, columns in
            let id = row.component(at: 0, columns, LECSId.self)
            let name = row.component(at: 1, columns, LECSName.self)
            ids.append(id)

            return [id, name]
        }

        world.deleteEntity(e2)

        world.process(system: system)

        XCTAssertEqual(2, ids.count)
    }

    func testMovingEntityBetweenArchetypes() throws {
        let world = createWorld()

        let e1 = world.createEntity("e1")
        world.addComponent(e1, LECSPosition2d(x: 1, y: 2))

        var firstCount = 0
        world.select([LECSPosition2d.self]) { _,_,_ in
            firstCount = firstCount + 1
        }

        world.addComponent(e1, LECSVelocity2d())

        var secondCount = 0
        world.select([LECSPosition2d.self]) { _,_,_ in
            secondCount = secondCount + 1
        }

        XCTAssertEqual(firstCount, secondCount)
    }

    /**
     Found a bug where removing components in a different order then they were added
     causes the next select to fail.

     I'm pretty sure this is happening because the previous archetype does not exist.
     */
    func testRemoveComponentNotUsedBySelect() throws {
        let world = createWorld()

        let e1 = world.createEntity("e1")
        world.addComponent(e1, LECSPosition2d(x: 1, y: 2))
        world.addComponent(e1, Velocity())
        world.addComponent(e1, LECSVelocity2d())

        var firstCount = 0
        world.select([LECSPosition2d.self]) { _,_,_ in
            firstCount = firstCount + 1
        }

        world.removeComponent(e1, component: Velocity.self)

        var secondCount = 0
        world.select([LECSPosition2d.self]) { _,_,_ in
            secondCount = secondCount + 1
        }

        XCTAssertEqual(firstCount, secondCount)
    }

    /**
     This reveals a bug with making sure components are removed when removing a component when the archetype needed doesn't
     exist yet and when you need to follow a backedge to an existing component.
     */
    func testRemoveComponentTheSameComponentsFromTwoDifferentEntities() throws {
        let world = createWorld()

        let e1 = world.createEntity("e1")
        world.addComponent(e1, LECSVelocity2d())
        world.addComponent(e1, Velocity())
        world.addComponent(e1, LECSPosition2d(x: 1, y: 2))
        let e2 = world.createEntity("e2")
        world.addComponent(e2, LECSVelocity2d())
        world.addComponent(e2, Velocity())
        world.addComponent(e2, LECSPosition2d(x: 2, y: 3))

        var firstCount = 0
        world.select([LECSPosition2d.self]) { _,_,_ in
            firstCount = firstCount + 1
        }

        world.removeComponent(e1, component: Velocity.self)
        world.removeComponent(e2, component: Velocity.self)

        var secondCount = 0
        world.select([LECSPosition2d.self]) { world, row, columns in
            let _ = row.component(at: 0, columns, LECSPosition2d.self)
            secondCount = secondCount + 1
        }

        XCTAssertEqual(firstCount, secondCount)
    }

    private func createWorld() -> LECSWorldFixedSize {
        LECSWorldFixedSize(archetypeManager: LECSArchetypeManager())
    }
}

struct Velocity: LECSComponent {

}
