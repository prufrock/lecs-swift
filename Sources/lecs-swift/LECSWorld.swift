//
//  LECSWorld.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

public typealias LECSEntityId = UInt
public typealias LECSArchetypeId = LECSEntityId
public typealias LECSComponentId = LECSEntityId
public typealias LECSSystemId = LECSEntityId
// The array of componentIds used to define the components an archetype holds.
public typealias LECSType = [LECSComponentId]
// Closely related to a LECSType, but used to describe the components requested.
public typealias LECSQuery = LECSType
public typealias LECSSize = Int
public typealias LECSRowId = Int
public typealias LECSRow = [LECSComponent]
// The index of the archetype where a value is stored.
public typealias LECSColumn = Int
public typealias LECSColumns = [LECSColumn]
public typealias LECSUpdate = (LECSWorld, LECSRow, LECSColumns) -> [LECSComponent]
public typealias LECSSelect = (LECSWorld, LECSRow, LECSColumns) -> Void
public typealias LECSSelector = [LECSComponent.Type]


/// The world is the facade for the ECS system. All access to the ECS system goes through LECSWorld.
public protocol LECSWorld {
    /// Creates an entity, adds it to the ECS, and returns its id.
    /// - Parameters:
    ///   - name: The name of the entity.
    /// - Returns: The id of the new entity.
    func createEntity(_ name: String) throws -> LECSEntityId

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
    func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T?

    /// Adds a component to the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to add the component to.
    ///   - component: The component to add to the entity.
    func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T) throws

    /// Removes a component from the entity.
    /// - Parameters:
    ///   - entityId: The id of the entity to remove the component from.
    ///   - component: The Type of the component to remove.
    func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) throws

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
    func addSystem(_ name: String, selector: [LECSComponent.Type], block: @escaping LECSUpdate) -> LECSSystemId

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component Ids selecting entities.
    ///   - block: The closure to run on the resulting data.
    func select(_ query: LECSQuery, _ block: LECSSelect)

    /// Runs a query to read from the world.
    /// - Parameters:
    ///   - query: The query of component types selecting entities.
    ///   - block: The closure to run on the resulting data.
    func select(_ query: [LECSComponent.Type], _ block: LECSSelect)

    /// Executes the system.
    /// - Parameters:
    ///   - system: The system to run.
    func process(system: LECSSystemId)
}

enum LECSWorldErrors: Error {
    case entityDoesNotExist
    case rowDoesNotExist
    case componentDoesNotExist
}

/// Create a LECSWorld with archetypes of size.
/// - Parameters
///   - archetypeSize: The size of the archetypes in LECSWorld.
public func LECSCreateWorld(archetypeSize: LECSSize = 2000) -> LECSWorld {
    return LECSWorldFixedSize(
        archetypeManager: LECSArchetypeManager(archetypeSize: archetypeSize)
    )
}

public class LECSWorldFixedSize: LECSWorld {
    private var archetypeManager: LECSArchetypeManager

    // The 0 entity is reserved for future use
    private var entityCounter: LECSEntityId = 1

    private var rootEntity: LECSEntityId = 0

    // systems
    private var systems: [LECSSystemId: LECSSystem] = [:]

    // indexes
    // entityRecord is a map of entity ids to records. The record contains the archetype and the row id.
    private var entityRecord: [LECSEntityId: LECSRecord] = [:]
    // typeComponent maps the Swift Type of a Component to a ComponentId
    private var typeComponent: [MetatypeWrapper: LECSComponentId] = [:]
    // nameEntityId maps the name of the entity to it's id
    private var nameEntityId: [LECSName:LECSEntityId] = [:]

    // caches
    private var queryCache: [String: [LECSArchetypeId:[LECSArchetypeRecord]]] = [:]

    init(archetypeManager: LECSArchetypeManager) {
        self.archetypeManager = archetypeManager

        entityRecord[rootEntity] = LECSRecord(
            entityId: rootEntity,
            archetype: archetypeManager.emptyArchetype,
            row: 0
        )
    }

    public func createEntity(_ name: String) throws -> LECSEntityId {
        let id = createEntity()

        try addComponent(id, LECSId(id: id))
        try addComponent(id, LECSName(name: name))

        // When there's an index for a component and the component changes how does the index get updated?
        nameEntityId[LECSName(name: name)] = id

        return id
    }

    public func deleteEntity(_ entityId: LECSEntityId) {
        guard let record = entityRecord[entityId], let archetype = archetypeManager.find(record.archetype.id) else {
            return
        }

        //TODO: process for updating indexes
        let name = try! getComponent(entityId, LECSName.self)!
        nameEntityId.removeValue(forKey: name)

        try! archetype.remove(record.row)
    }

    public func entity(named: LECSName) -> LECSEntityId? {
        nameEntityId[named]
    }

    public func hasComponent(_ entityId: LECSEntityId, _ component: LECSComponent.Type) -> Bool {
        // Find the id of the component
        guard let componentId = typeComponent[component] else {
            return false
        }
        guard let archetype = entityRecord[entityId]?.archetype else {
            return false
        }
        return archetypeManager.componentOf(archetype, componentId: componentId)
    }

    public func getComponent<T>(_ entityId: LECSEntityId, _ component: T.Type) throws -> T? {
        let record = entityRecord[entityId]!

        return try record.getComponent(entityId, typeComponent[T.self]!, T.self)
    }

    public func addComponent<T: LECSComponent>(_ entityId: LECSEntityId, _ component: T) throws {
        guard let record = entityRecord[entityId] else {
            throw LECSWorldErrors.entityDoesNotExist
        }
        let componentId = typeComponent[T.self] ?? createComponent(T.self)

        // if the records archetype already has the component just updated the row
        if let archetypeMap = archetypeManager.findArchetypesWithComponent(componentId), let archetypeRecord = archetypeMap[record.archetype.id] {
            try! record.archetype.update(record.row, column: archetypeRecord.column, component: component)
            // the component was changed--update indexes? event(component, update, previous value, new value)
            return
        }

        //TODO: Move all of this into the ArchetypeManager
        let oldArchetype = record.archetype
        guard let row = try oldArchetype.remove(record.row) else {
            throw LECSWorldErrors.rowDoesNotExist
        }

        let newArchetype = archetypeManager.nearestArchetype(to: oldArchetype, with: componentId)

        let unorderedRow = row + [component]
        let unorderedComponents = oldArchetype.type + [componentId]
        let newRow = try newArchetype.insert(
            unorderedComponents.aligned(to: unorderedRow).map { $0.1 }
        )

        entityRecord[entityId] = LECSRecord(
            entityId: entityId,
            archetype: newArchetype,
            row: newRow
        )
        // ☎️ the archetype manager needs a way to tell the world a new archetype has been created so dump cache
        newArchetypeCreated()
        //TODO: Return the row
        // updated indexes...
    }

    public func removeComponent(_ entityId: LECSEntityId, component: LECSComponent.Type) throws {
        guard let record = entityRecord[entityId] else {
            throw LECSWorldErrors.entityDoesNotExist
        }
        guard let componentId = typeComponent[component] else {
            throw LECSWorldErrors.componentDoesNotExist
        }

        entityRecord[entityId] = try! archetypeManager.removeComponent(from: record, componentId: componentId)

        //dump the cache
        newArchetypeCreated()

        //TODO: Return the row
    }

    public func addSystem(_ name: String, selector: [LECSComponentId], block: @escaping LECSUpdate) -> LECSSystemId {
        let system = LECSSystem(name: name, selector: selector, lambda: block)
        let id = entity()
        systems[id] = system
        return id
    }

    public func addSystem(_ name: String, selector: [LECSComponent.Type], block: @escaping LECSUpdate) -> LECSSystemId {
        addSystem(name, selector: selector.map{ typeComponent[$0]! }, block: block)
    }

    public func process(system id: LECSSystemId) {
        let system = systems[id]!
        update(system.selector) { world, components, columns in
            return system.lambda(world, components, columns)
        }
    }

    public func select(_ query: [LECSComponent.Type], _ block: LECSSelect) {
        select(query.map{ typeComponent[$0]! }, block)
    }

    public func select(_ query: LECSQuery, _ block: LECSSelect) {
        // If there aren't any components in the query there is no work to be done.
        guard query.isNotEmpty else {
            return
        }

        for (archetypeId, archetypeRecords) in findArchetypesWithComponents(query) {
            let archetype = archetypeManager.find(archetypeId)!
            (0..<(archetype.count)).forEach { rowId in
                let columns: LECSColumns = archetypeRecords.map { $0.column }
                if archetype.exists(rowId) {
                    block(self, archetype.row(rowId)!, columns)
                }
            }
        }
    }

    private func update(_ query: LECSQuery, _ block: (LECSWorld, LECSRow, LECSColumns) -> LECSRow) {
        // If there aren't any components in the query there is no work to be done.
        guard query.isNotEmpty else {
            return
        }

        for (archetypeId, archetypeRecords) in findArchetypesWithComponents(query) {
            let archetype = archetypeManager.find(archetypeId)!
            (0..<archetype.count).forEach { rowId in
                let columns: LECSColumns = archetypeRecords.map { $0.column }
                if archetype.exists(rowId) {
                    let updatedComponents = block(self, archetype.row(rowId)!, columns)
                    var uc = 0
                    columns.forEach {
                        try! archetype.update(rowId, column: $0, component: updatedComponents[uc])
                        uc += 1
                    }
                }
            }
        }
    }

    private func entity() -> LECSEntityId {
        let id = entityCounter
        entityCounter += 1
        return id
    }

    private func createEntity() -> LECSEntityId {
        let id = entity()
        let rowId = try! archetypeManager.emptyArchetype.insert([])
        entityRecord[id] = LECSRecord(
            entityId: id,
            archetype: archetypeManager.emptyArchetype,
            row: rowId
        )
        return id
    }

    private func createComponent(_ componentType: LECSComponent.Type) -> LECSComponentId {
        // Generate an id for the component
        let id = entity()
        // Store the component in the index
        typeComponent[componentType] = id

        return id
    }

    private func createArchetype(type: LECSType) -> LECSArchetype {
        let archetype = archetypeManager.createArchetype(type: type)

        newArchetypeCreated()

        return archetype
    }


    private func findArchetypesWithComponents(_ query: LECSQuery) -> [LECSArchetypeId:[LECSArchetypeRecord]] {
        if let positions =  queryCache[queryHash(query)] {
            return positions
        }
        // stores one and only one of each archetype
        // knows the location of each component in each archetype
        var archetypePositions: [LECSArchetypeId:[LECSArchetypeRecord]] = [:]

        // Find the archetype that matches the query
        // Process in component order so they can be read out in order
        query.forEach { componentType in
            archetypeManager.findArchetypesWithComponent(componentType)?.forEach { archetypeId, archetypeRecord in
                archetypePositions.updateCollection(archetypeRecord, forKey: archetypeId)
            }
        }

        // the number of components located in each archetype must be the same as the components queried
        let positions = archetypePositions.filter { $1.count == query.count }
        queryCache[queryHash(query)] = positions
        return positions
    }

    private func queryHash(_ query: LECSQuery) -> String {
        query.map { String($0) }.joined(separator: ":")
    }

    private func newArchetypeCreated() {
        // wipe the query cache for now, eventually it may be worth only clearing queries cached with same components as the archetype
        queryCache = [:]
    }
}

struct LECSArchetypeRecord{
    let column: Int
}
