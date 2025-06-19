//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSWorldTests: XCTestCase {
    func testCreateAndDeleteEntity() {
        let world = LECSWorldFixedSize(archetypeSize: 10)

        _ = world.createEntity("spear")

        var count = 0
        world.select([LECSName.self]) { _, _ in
            count += 1
        }

        XCTAssertEqual(1, count)

        world.deleteEntity(world.entity(named: LECSName("spear"))!)

        count = 0
        world.select([LECSName.self]) { _, _ in
            count += 1
        }

        XCTAssertEqual(0, count)
    }

    func testHasComponent() {
        let world = LECSWorldFixedSize(archetypeSize: 10)

        let entity = world.createEntity("spear")
        let otherEntity = world.createEntity("sheild")

        world.addComponent(otherEntity, LECSVelocity2d())

        XCTAssertTrue(world.hasComponent(entity, LECSName.self))
        XCTAssertFalse(world.hasComponent(entity, LECSVelocity2d.self))

        world.removeComponent(otherEntity, component: LECSVelocity2d.self)

        XCTAssertFalse(world.hasComponent(otherEntity, LECSVelocity2d.self))
    }

    func testAddSystem() {
        let world = LECSWorldFixedSize(archetypeSize: 10)

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSVelocity2d())
        world.addComponent(spear, LECSPosition2d())

        let system = world.addSystem(
            "spear system",
            selector: [LECSPosition2d.self]
        ) { components, columns in
            return [LECSPosition2d(x: 2, y: 0)]
        }

        world.process(system: system)

        let position = world.getComponent(
            spear,
            LECSPosition2d.self
        )!

        XCTAssertEqual(2.0, position.x)
    }

    func testAddSystemWorldScoped() {
        let world = LECSWorldFixedSize(archetypeSize: 10)

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSVelocity2d())
        world.addComponent(spear, LECSPosition2d())

        let accelertor = world.createEntity("accelerator")
        world.addComponent(accelertor, LECSVelocity2d(x: 10, y: 5))

        let system = world.addSystemWorldScoped(
            "spear system",
            selector: [LECSPosition2d.self]
        ) { world, components, columns in
            let foundFork = world.entity("accelerator")!
            let foundVelocity = world.getComponent(foundFork, LECSVelocity2d.self)!
            return [LECSPosition2d(x: 2 + foundVelocity.x, y: 0)]
        }

        world.processSystemWorldScoped(system: system)

        let position = world.getComponent(
            spear,
            LECSPosition2d.self
        )!

        XCTAssertEqual(12.0, position.x)
    }


    struct TagWall: LECSComponent {
        let wall = true
    }

    struct TagCollides: LECSComponent {
        let collides = true
    }
}
