//
//  LECSWorld.swift
//
//
//  Created by David Kanenwisher on 4/8/24.
//

import Foundation

public typealias LECSEntityId = UInt
public typealias LECSSystemId = LECSEntityId
public typealias LECSUpdate = (LECSRow, LECSColumns) -> LECSRow
public typealias LECSSelect = (LECSRow, LECSColumns) -> Void

/// The world is the facade for the ECS system. All access to the ECS system goes through LECSWorld.
public protocol LECSWorld {
    /// Creates an entity, adds it to the ECS, and returns its id.
    /// - Parameters:
    ///   - name: The name of the entity.
    /// - Returns: The id of the new entity.
    func createEntity(_ name: String) -> LECSEntityId

    /// Deletes the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to delete
    /// - Returns: void
    func deleteEntity(_ entityId: LECSEntityId)

    /// Finds the entity with the name
    /// - Parameters:
    ///   - named: The name of the entity
    /// - Returns: The id of the found entity.
    func entity(named: LECSName) -> LECSEntityId?

    /// Checks to see if the entity has a component.
    /// - Parameters:
    ///   - entityId: The id of the entity to check.
    ///   - component: The Type of the component.
    /// - Returns: whether or not the entity has the component
    func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool

    /// Finds the component on the entity if it exists.
    /// - Parameters:
    ///   - entityId: The id of the entity to get the entity for.
    ///   - component: The Type of the component.
    /// - Returns: The component requested if it exists on the entity.
    func getComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T.Type) -> T?

    /// Adds a component to the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to add the component to.
    ///   - component: The component to add to the entity.
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T)

    /// Removes a component from the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to remove the component from.
    ///   - component: The Type of the component to remove.
    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type)

    /// Adds a system to the world.
    /// - Parameters:
    ///   - name: The name of the system.
    ///   - selector: The query of component Ids selecting entities to process with the system.
    ///   - block: The closure to run on the results of the query.
    /// - Returns: The id of the system.
    func addSystem(_ name: String, selector: LECSQuery, block: @escaping LECSUpdate) -> LECSSystemId

    /// Adds a system to the world.
    /// - Parameters:
    ///   - name: The name of the system.
    ///   - selector: The query of component types selecting entities to process with the system.
    ///   - block: The closure to run on the results of the query.
    /// - Returns: The id of the system.
    /// TODO: might have to get rid of this
    func addSystem(_ name: String, selector: [Int], block: @escaping LECSUpdate) -> LECSSystemId

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component Ids selecting entities.
    ///   - block: The closure to run on the resulting data.
    func select(_ query: LECSQuery, _ block: LECSSelect)

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component types selecting entities.
    ///   - block: The closure to run on the resulting data.
    /// TODO: might have to get rid of this
    func select(_ query: [Int], _ block: LECSSelect)

    /// Executes the system.
    /// - Parameters:
    ///   - system: The system to run.
    func process(system: LECSSystemId)

    /// Adds an obverser that receives information about the operations of LECSWorld.
    /// - Parameters:
    ///   - observer: The observer to update.
    func addObserver(_ observer: LECSWorldObserver)
}

public func LECSCreateWorld(archetypeSize: Int) -> LECSWorld {
    LECSWorldFixedSize(archetypeSize: archetypeSize)
}

class LECSWorldFixedSize: LECSWorld {

    private let chart: LECSFixedComponentChart

    private var entityCounter:UInt = 0 // reserve 0
    private var entityMap: [LECSEntityId:LECSRowId] = [:]

    private var systemCounter:UInt = 0 // reserve 0
    private var systemMap: [LECSSystemId:LECSSystem] = [:]


    // Indexes map LECSEntityId to another attribute.
    private var indexEntityName: [String:LECSEntityId] = [:]

    private var observers: [LECSWorldObserver] = []

    // Used to create a unique identifier for each select.
    private var selectCounter: UInt = 0

    init(archetypeSize: Int) {
        chart = LECSFixedComponentChart(factory: LECSArchetypeFactory(size: archetypeSize))
    }

    func createEntity(_ name: String) -> LECSEntityId {
        // critical region
        var row = chart.createRow()

        guard indexEntityName[name] == nil else {
            fatalError("An index already has the name:[\(name)]. Did you forget to delete the previous instance?")
        }

        entityCounter += 1
        let entityId = entityCounter

        row = chart.addComponentTo(row: row, component: LECSId(entityId))
        row = chart.addComponentTo(row: row, component: LECSName(name))

        // Update indexes
        entityMap[entityId] = row
        indexEntityName[name] = entityId

        observers.forEach { $0.entityCreated(id: entityId, name: name) }

        return entityId
    }
    
    func deleteEntity(_ entityId: LECSEntityId) {
        // critical region
        guard let row = entityMap[entityId] else {
            fatalError("An entity with entityId:[\(entityId)] does not exist. Did you already delete it?")
        }

        let name = chart.readComponentFrom(row: row, type: LECSName.self)

        indexEntityName.removeValue(forKey: name.name)

        chart.delete(row: row)

        observers.forEach { $0.entityDeleted(id: entityId, name: name.name) }
    }
    
    func entity(named: LECSName) -> LECSEntityId? {
        indexEntityName[named.name]
    }
    
    func hasComponent(_ entityId: LECSEntityId, _ component: any LECSComponent.Type) -> Bool {
        let row = getRow(for: entityId)
        return chart.component(in: row, type: component)
    }
    
    func getComponent<T:LECSComponent>(_ entityId: LECSEntityId, _ component: T.Type) -> T? {
        let row = getRow(for: entityId)
        return chart.readComponentFrom(row: row, type: component)
    }
    
    func addComponent<T:LECSComponent>(_ entityId: LECSEntityId, _ component: T) {
        // critical region
        let row = getRow(for: entityId)
        let newRow = chart.addComponentTo(row: row, component: component)

        update(entityId: entityId, newRow: newRow)

        observers.forEach { $0.componentAdded(id: entityId, component: component) }
    }

    func removeComponent(_ entityId: LECSEntityId, component: any LECSComponent.Type) {
        // TODO: Does it need to be 'any'?
        // critical region
        let row = getRow(for: entityId)
        let newRow = chart.removeComponentFrom(row: row, type: component)
        update(entityId: entityId, newRow: newRow)

        observers.forEach { $0.componentRemoved(id: entityId, component: component) }
    }
    
    func addSystem(_ name: String, selector: LECSQuery, block: @escaping LECSUpdate) -> LECSSystemId {
        // critical region
        let systemId = systemCounter
        systemCounter += 1
        let componentIds = chart.convertQueryToComponentIds(selector)
        systemMap[systemId] = LECSSystem(componentIds: componentIds, block: block)

        observers.forEach { $0.systemAdded(id: systemId, name: name, selector: selector) }

        return systemId
    }
    
    func addSystem(_ name: String, selector: [Int], block: @escaping LECSUpdate) -> LECSSystemId {
        //TODO: implement
        fatalError("not implemented")
    }
    
    func select(_ query: LECSQuery, _ block: (LECSRow, LECSColumns) -> Void) {
        // might need synchronization here, but it might be good enough to assign it here then increment it.
        // it would be nice to have some sort of atomic int...
        let count = selectCounter
        selectCounter += 1

        observers.forEach { $0.selectBegin(id: count, query: query) }

        chart.select(query, block: block)

        observers.forEach { $0.selectEnd(id: count, query: query) }
    }
    
    func select(_ query: [Int], _ block: (LECSRow, LECSColumns) -> Void) {
        //TODO: implement
        fatalError("not implemented")
    }
    
    func process(system id: LECSSystemId) {
        guard let system = systemMap[id] else {
            fatalError("SystemId[\(id)] doesn't exist.")
        }

        observers.forEach { $0.processBegin(id: id) }

        chart.update(system.componentIds, block: system.block)

        observers.forEach { $0.processEnd(id: id) }
    }

    func addObserver(_ observer: LECSWorldObserver) {
       observers.append(observer)
    }

    private func getRow(for entityId: LECSEntityId) -> LECSRowId {
        guard let row = entityMap[entityId] else {
            fatalError("An entity with entityId:[\(entityId)] does not exist. Was it deleted?")
        }

        return row
    }

    private func update(entityId: LECSEntityId, newRow: LECSRowId) {
        entityMap[entityId] = newRow
    }
}


private struct LECSSystem {
    let componentIds: [LECSComponentId]
    let block: LECSUpdate
}
