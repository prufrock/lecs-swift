//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/14/23.
//

import Foundation

typealias LECSArchetypeMap = [LECSArchetypeId: LECSArchetypeRecord]

struct LECSArchetypeManager {
    private var archetypeCounter: LECSArchetypeId = 1

    let emptyArchetype: LECSArchetype = LECSArchetypeFixedSize(
        id: 1,
        type: [],
        columns: [],
        table: LECSArrayTable(size: 0, columns: [])
    )

    private let archetypeSize: LECSSize

    // archetypeIndex maps archetype ids to archetypes
    private var archetypeIndex: [LECSArchetypeId: LECSArchetype] = [:]
    // componentArchetype maps component ids to the archetypes their in and the column they are in.
    // this makes determining if a component is in an archetype and retrieval fast
    private var componentArchetype: [LECSComponentId : LECSArchetypeMap] = [:]

    init(archetypeSize: LECSSize = 10) {
        self.archetypeSize = archetypeSize

        archetypeIndex[emptyArchetype.id] = emptyArchetype
    }

    /// Checks to see if the component is in the archetype
    /// - Parameters:
    ///   - archetype: The archetype to look in.
    ///   - componentId: The componentId to look for.
    /// - Returns: whether or not the component is in the archetype.
    func componentOf(_ archetype: LECSArchetype, componentId: LECSComponentId) -> Bool {
        componentArchetype[componentId]?[archetype.id] != nil
    }

    func find(_ archetypeId: LECSArchetypeId) -> LECSArchetype? {
        archetypeIndex[archetypeId]
    }

    func findArchetypesWithComponent(_ component: LECSComponentId) -> LECSArchetypeMap {
        componentArchetype[component]!
    }

    mutating func createArchetype(columns: LECSColumnTypes, type: LECSType) -> LECSArchetype {
        let id = newId()

        return archetype(id: id, columns: columns, type: type)
    }

    mutating func updateComponentArchetypeMap(_ archetype: LECSArchetype) {
        // iterate over the type in the archetype
        for (column, componentId) in archetype.type.enumerated() {
            // get the map for the component
            var map = componentArchetype[componentId] ?? [:]
            // add the archetype to the map
            map[archetype.id] = LECSArchetypeRecord(column: column)
            // update the map in the index
            componentArchetype[componentId] = map
        }
    }

    mutating func store(archetype: LECSArchetype) {
        archetypeIndex[archetype.id] = archetype
    }
    
    mutating func nearestArchetype<T: LECSComponent>(to archetype: LECSArchetype, with componentId: LECSComponentId, component: T) -> LECSArchetype {
        let newArchetype = archetype.addComponent(componentId) ?? createArchetype(
            columns: archetype.columns + [T.self],
            type: archetype.type + [componentId]
        )
        archetype.setAddEdge(componentId, newArchetype)
        newArchetype.setRemoveEdge(componentId, archetype)
        store(archetype: newArchetype)
        updateComponentArchetypeMap(newArchetype)
        return newArchetype
    }

    mutating private func newId() -> LECSArchetypeId {
        let id = archetypeCounter
        archetypeCounter += 1
        return id
    }

    private func archetype(id: LECSArchetypeId, columns: LECSColumnTypes, type: LECSType) -> LECSArchetype {
        LECSArchetypeFixedSize(
            id: id,
            type: type,
            columns: columns,
            size: archetypeSize
        )
    }
}
