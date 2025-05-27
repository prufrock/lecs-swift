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

        _ = world.createEntity("spear")

        XCTAssertEqual(1, observer.entitiesCreated.count)
    }
}

class Watcher: LECSWorldObserver {
    var entitiesCreated: [String:LECSEntityId] = [:]

    func entityCreated(id: LECSEntityId, name: String) {
        entitiesCreated[name] = id
    }
}
