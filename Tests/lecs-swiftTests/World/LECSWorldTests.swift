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
        let world = LECSWorldFixedSize()

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
        let world = LECSWorldFixedSize()

        let entity = world.createEntity("spear")
        let otherEntity = world.createEntity("sheild")

        world.addComponent(otherEntity, LECSVelocity2d())

        XCTAssertTrue(world.hasComponent(entity, LECSName.self))
        XCTAssertFalse(world.hasComponent(entity, LECSVelocity2d.self))

        world.removeComponent(otherEntity, component: LECSVelocity2d.self)

        XCTAssertFalse(world.hasComponent(otherEntity, LECSVelocity2d.self))
    }

    func testAddSystem() {
        let world = LECSWorldFixedSize()

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSPosition2d())

        let system = world.addSystem(
            "spear system",
            selector: [LECSPosition2d.self]
        ) { components, columns in
            return components.update(
                [(columns[0], LECSPosition2d(x: 2, y: 0))]
            )
        }

        world.process(system: system)

        let position = world.getComponent(
            spear,
            LECSPosition2d.self
        )!

        XCTAssertEqual(2.0, position.x)
    }
}
