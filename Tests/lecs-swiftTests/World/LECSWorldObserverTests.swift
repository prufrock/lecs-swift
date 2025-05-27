//
//  AnyMetatypeWrapperTests.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import XCTest
@testable import lecs_swift

final class LECSWorldObserverTests: XCTestCase {
    func testCreateAndDeleteEntity() {
        let world = LECSWorldFixedSize(archetypeSize: 10)
        let observer = Watcher()
        world.addObserver(observer)

        let spear = world.createEntity("spear")

        XCTAssertEqual(1, observer.entitiesCreated.count)

        world.deleteEntity(spear)

        XCTAssertEqual(1, observer.entitiesDeleted.count)
    }

    func testAddComponent() {
        let world = LECSWorldFixedSize(archetypeSize: 10)
        let observer = Watcher()
        world.addObserver(observer)

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSPosition2d())

        XCTAssertEqual(1, observer.componentsAdded.count)
        XCTAssertEqual("\(LECSPosition2d())", observer.componentsAdded[spear]!)
    }
}

class Watcher: LECSWorldObserver {
    var entitiesCreated: [String:LECSEntityId] = [:]
    var entitiesDeleted: [String:LECSEntityId] = [:]
    var componentsAdded: [LECSEntityId: String] = [:]

    func entityCreated(id: LECSEntityId, name: String) {
        entitiesCreated[name] = id
    }

    func entityDeleted(id: LECSEntityId, name: String) {
        entitiesDeleted[name] = id
    }

    func componentAdded<T: LECSComponent>(id: LECSEntityId, component: T) {
        componentsAdded[id] = "\(component)"
    }
}
