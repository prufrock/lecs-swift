//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/14/23.
//

import Foundation

typealias LECSArchetypeMap = [LECSArchetypeId: LECSArchetypeRecord]

struct LECSArchetypeManager {
    private var archetypeCounter: LECSArchetypeId = 2

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

    mutating func createArchetype(columns: LECSColumnTypes, type: LECSType, back: LECSArchetype? = nil) -> LECSArchetype {
        let id = newId()

        return archetype(id: id, columns: columns, type: type, back: back)
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
    
    mutating func nearestArchetype<T: LECSComponent>(to archetype: LECSArchetype, with componentId: LECSComponentId, component: T.Type) -> LECSArchetype {

        let newArchetype: LECSArchetype
        if ((archetype.type.last ?? 0) <= componentId) {
            /// When the componentId is greater than the last
            /// component in the archetype ordering can be
            /// maintained following the current archetype's
            /// add edge. The two components should not be equal.
            newArchetype = archetype.addComponent(componentId) ?? createArchetype(
                columns: archetype.columns + [component],
                type: archetype.type + [componentId],
                back: archetype
            )
        } else {
            /// When the componentId is less than the last
            /// component in the archetype order has to be
            /// maintained by backing up and finding a path
            /// to the archetype with the new component.
            let sorted = (archetype.type + [componentId]).sorted()

            var currentArchetype = emptyArchetype
            var componentsSoFar: [LECSComponentId] = []
            sorted.forEach {
                componentsSoFar.append($0)
                currentArchetype = currentArchetype.addComponent($0) ??
                createArchetype(
                    columns: componentsSoFar.map {
                    currentArchetype.columns[componentArchetype[$0]![currentArchetype.id]!.column]
                    },
                    type: componentsSoFar,
                    back: currentArchetype
                )
            }

            newArchetype = currentArchetype
        }

        store(archetype: newArchetype)
        updateComponentArchetypeMap(newArchetype)
        return newArchetype
    }

    mutating private func newId() -> LECSArchetypeId {
        let id = archetypeCounter
        archetypeCounter += 1
        return id
    }

    private func archetype(id: LECSArchetypeId, columns: LECSColumnTypes, type: LECSType, back: LECSArchetype? = nil) -> LECSArchetype {
        let a = LECSArchetypeFixedSize(
            id: id,
            type: type,
            columns: columns,
            size: archetypeSize
        )
        if let edge = back {
            if let id = type.last {
                edge.setAddEdge(id, a)
                a.setRemoveEdge(id, edge)
            }
        }

        return a
    }
}
