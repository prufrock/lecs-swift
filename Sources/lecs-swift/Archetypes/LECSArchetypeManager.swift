//
//  LECSArchetypeManager.swift
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
        table: LECSArrayTable(size: 0, columnTypes: [])
    )

    private let archetypeSize: LECSSize

    // archetypeIndex maps archetype ids to archetypes
    private var archetypeIndex: [LECSArchetypeId: LECSArchetype] = [:]
    // componentArchetype maps component ids to the archetypes they're in and the column they're in.
    // this makes determining if a component is in an archetype and retrieval fast
    private var componentArchetype: [LECSComponentId: LECSArchetypeMap] = [:]

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

    func findArchetypesWithComponent(_ component: LECSComponentId) -> LECSArchetypeMap? {
        componentArchetype[component]
    }

    mutating func updateArchetypeFor<T: LECSComponent>(
        record: LECSRecord,
        component: T,
        componentId: LECSComponentId
    ) -> LECSRecord {
        if let record = updateCurrentArchetype(record: record, component: component, componentId: componentId) {
            return record
        } else {
            return updateNearestArchetype(record: record, component: component, componentId: componentId)
        }
    }

    mutating func createArchetype(type: LECSType, parent: LECSArchetype? = nil) -> LECSArchetype {
        let id = newId()

        let newArchetype = archetype(id: id, type: type, parent: parent)

        store(archetype: newArchetype)
        updateComponentArchetypeMap(newArchetype)

        return newArchetype
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
    
    mutating func nearestArchetype(to archetype: LECSArchetype, with componentId: LECSComponentId) -> LECSArchetype {

        let newArchetype: LECSArchetype
        if ((archetype.type.last ?? 0) <= componentId) {
            /// When the componentId is greater than the last
            /// component in the archetype ordering can be
            /// maintained following the current archetype's
            /// add edge. The two components should not be equal.
            //TODO: should still be able to follow add edges, the work just changes when creating the new Archetype.
            newArchetype = archetype.addComponent(componentId) ?? createArchetype(
                type: archetype.type + [componentId],
                parent: archetype
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
                    type: componentsSoFar,
                    parent: currentArchetype
                )
            }

            newArchetype = currentArchetype
        }

        return newArchetype
    }

    mutating func removeComponent(from record: LECSRecord, componentId: LECSComponentId) throws -> LECSRecord {
        // don't do anything if the component isn't in the current archetype
        guard findArchetypesWithComponent(componentId)![record.archetype.id] != nil else {
            return record
        }

        let oldArchetype = record.archetype
        guard var row = oldArchetype.remove(record.row) else {
            throw LECSWorldErrors.rowDoesNotExist
        }
        let componentPosition = findArchetypesWithComponent(componentId)![oldArchetype.id]!.column
        // remove the component from the row
        row.remove(at: componentPosition)

        // If we've already gone back this way before save some work.
        if let backArchetype = record.archetype.removeComponent(componentId) {
            let rowId = backArchetype.insert(row)
            return LECSRecord(entityId: record.entityId, archetype: backArchetype, row: rowId)
        }

        // Don't make a new archetype as a back edge, instead start from the empty archetype. If one already exists use it.
        // Avoids Archetypes with duplicate Types hanging off of different edges.
        var newType = oldArchetype.type
        newType.remove(at: componentPosition)
        let newArchetype = archetypeFor(type: newType)

        // Next time there will be a back edge to follow.
        oldArchetype.setRemoveEdge(componentId, newArchetype)

        // store the row
        let rowId = newArchetype.insert(row)

        return LECSRecord(entityId: record.entityId, archetype: newArchetype, row: rowId)
    }

    private mutating func archetypeFor(type: LECSType) -> LECSArchetype {
        var archetype = emptyArchetype
        type.forEach {
            archetype = archetype.addComponent($0) ?? createArchetype(type: archetype.type + [$0], parent: archetype)
        }

        return archetype
    }

    mutating private func newId() -> LECSArchetypeId {
        let id = archetypeCounter
        archetypeCounter += 1
        return id
    }

    private mutating func updateCurrentArchetype<T: LECSComponent>(
        record: LECSRecord,
        component: T,
        componentId: LECSComponentId
    ) -> LECSRecord? {
        // if the record's archetype already has the component just update the row
        guard let column = column(of: record.archetype, for: componentId) else {
            return nil
        }

        record.archetype.update(record.row, column: column, component: component)

        return record
    }

    private mutating func updateNearestArchetype<T: LECSComponent>(
        record: LECSRecord,
        component: T,
        componentId: LECSComponentId
    ) -> LECSRecord {
        let oldArchetype = record.archetype
        guard let row = oldArchetype.remove(record.row) else {
            fatalError("Dang, the row for Entity:\(record.entityId) could not be removed from the old archetype. It's strange because the record was found. Something may have gotten out of sync between the record and the archetype it was stored in. It's likely a bug in the package and not in your application.")
        }

        let newArchetype = nearestArchetype(to: oldArchetype, with: componentId)

        // The componentIds on an archetype are ordered from smallest to largest.
        // Append the new component to the old archetype and the row, so they are out of order in the same way.
        // Then use the componentIds to order the components.
        let newRow = newArchetype.insert(
            alignComponentsTo(oldType: oldArchetype.type, with: componentId, oldRow: row, component: component)
        )

        return LECSRecord(
            entityId: record.entityId,
            archetype: newArchetype,
            row: newRow
        )
    }

    private func column(of archetype: LECSArchetype, for componentId: LECSComponentId) -> Int? {
        guard
            let archetypeMap = findArchetypesWithComponent(componentId),
            let archetypeRecord = archetypeMap[archetype.id]
        else {
            return nil
        }

        return archetypeRecord.column
    }

    private func archetype(id: LECSArchetypeId, type: LECSType, parent: LECSArchetype? = nil) -> LECSArchetype {
        let archetype = LECSArchetypeFixedSize(
            id: id,
            type: type,
            size: archetypeSize
        )
        if let previousArchetype = parent, let id = type.last {
            previousArchetype.setAddEdge(id, archetype)
            archetype.setRemoveEdge(id, previousArchetype)
        }

        return archetype
    }

    private func alignComponentsTo<T: LECSComponent>(
        oldType type: LECSType,
        with componentId: LECSComponentId,
        oldRow: [LECSComponent],
        component: T
    ) -> LECSRow {
        (type + [componentId]).aligned(with: (oldRow + [component])).map { $0.1 }
    }
}
