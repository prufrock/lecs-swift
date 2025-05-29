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

    func testAddAndRemoveComponent() {
        let world = LECSWorldFixedSize(archetypeSize: 10)
        let observer = Watcher()
        world.addObserver(observer)

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSPosition2d())

        XCTAssertEqual(1, observer.componentsAdded.count)
        XCTAssertEqual("\(LECSPosition2d())", observer.componentsAdded[spear]!)

        world.removeComponent(spear, component: LECSPosition2d.self)
        XCTAssertEqual(1, observer.componentsRemoved.count)
        XCTAssertEqual("\(LECSPosition2d.self)", observer.componentsRemoved[spear]!)
    }

    func testAddSystemAndSelectAndProcess() {
        let world = LECSWorldFixedSize(archetypeSize: 10)
        let observer = Watcher()
        world.addObserver(observer)

        let spear = world.createEntity("spear")
        world.addComponent(spear, LECSPosition2d())

        let systemId = world.addSystem(
            "collisions",
            selector: [LECSPosition2d.self], block: {rows, columns in rows }
        )

        XCTAssertEqual(1, observer.systemsAdded.count)
        XCTAssertEqual(("collisions"), observer.systemsAdded[systemId]!.0)
        XCTAssertEqual(("[lecs_swift.LECSPosition2d]"), observer.systemsAdded[systemId]!.1)

        world.select([LECSPosition2d.self], { rows, columns in _ = rows.count })

        XCTAssertEqual(1, observer.selectsBegan.count)
        XCTAssertEqual(1, observer.selectsEnded.count)

        world.process(system: systemId)

        XCTAssert(observer.processBeginCalls[systemId]! == 1)
        XCTAssert(observer.processEndCalls[systemId]! == 1)
    }
}

class Watcher: LECSWorldObserver {
    var entitiesCreated: [String:LECSEntityId] = [:]
    var entitiesDeleted: [String:LECSEntityId] = [:]
    var componentsAdded: [LECSEntityId: String] = [:]
    var componentsRemoved: [LECSEntityId: String] = [:]
    var systemsAdded: [LECSSystemId: (String, String)] = [:]
    var selectsBegan: [UInt: LECSQuery] = [:]
    var selectsEnded: [UInt: LECSQuery] = [:]
    var processBeginCalls: [LECSSystemId: Int] = [:]
    var processEndCalls: [LECSSystemId: Int] = [:]

    func entityCreated(id: LECSEntityId, name: String) {
        entitiesCreated[name] = id
    }

    func entityDeleted(id: LECSEntityId, name: String) {
        entitiesDeleted[name] = id
    }

    func componentAdded<T: LECSComponent>(id: LECSEntityId, component: T) {
        componentsAdded[id] = "\(component)"
    }

    func componentRemoved(id: LECSEntityId, component: LECSComponent.Type) {
        componentsRemoved[id] = "\(component)"
    }

    func systemAdded(id: LECSSystemId, name: String, selector: LECSQuery) {
        systemsAdded[id] = (name, "\(selector)")
    }

    func selectBegin(id: UInt, query: LECSQuery) {
        selectsBegan[id] = query
    }

    func selectEnd(id: UInt, query: LECSQuery) {
        selectsEnded[id] = query
    }

    func processBegin(id: LECSSystemId) {
        processBeginCalls[id] = (processBeginCalls[id] ?? 0) + 1
    }

    func processEnd(id: LECSSystemId) {
        processEndCalls[id] = (processEndCalls[id] ?? 0) + 1
    }
}
