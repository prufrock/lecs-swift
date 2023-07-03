//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

typealias LECSEntityId = UInt
typealias LECSArchetypeId = LECSEntityId
typealias LECSComponentId = LECSEntityId
typealias LECSType = [LECSComponentId]
typealias LECSSize = Int
typealias LECSRowId = Int
typealias LECSRow = [LECSComponent]
typealias LECSColumns = [LECSComponent.Type]

/// An Archetype manages the storage of entities with a specific set of components.
protocol LECSArchetype {
    // The id of the archetype.
    var id: LECSArchetypeId { get }
    // The ordered list of components in the archetype.
    var type: LECSType { get }
    // The ordered list of component types in the archetype.
    var columns: LECSColumns { get }

    /// Inserts a new row into the archetype.
    /// - Parameter values: A list of components to insert into the archetype.
    /// - Returns: The row id of the newly inserted row.
    /// - Throws: If there is an error inserting the row, usually because the archetype is full.
    func insert(_ values: LECSRow) throws -> LECSRowId

    /// Reads a row from the archetype.
    /// - Parameter rowId: The id of the row to read.
    /// - Returns: The row requested.
    /// - Throws: If there is an error reading the row, usually because the row id is out of bounds.
    func read(_ rowId: LECSRowId) throws -> LECSRow?

    /// Removes a row from the archetype.
    /// - Parameter rowId: The id of the row to remove.
    /// - Returns: The row removed
    /// - Throws: If there is an error removing the row.
    func remove(_ rowId: LECSRowId) throws -> LECSRow?

    /// Checks to see if the archetype has a component.
    /// - Parameter component: The id of the component to check.
    /// - Returns: Whether or not the archetype has the component.
    func hasComponent(_ component: LECSComponentId) -> Bool

    /// Gets a component from the archetype.
    /// - Parameters:
    ///   - rowId: The id of the row to get the component from.
    ///   - componentId: The id of the component to get.
    ///   - componentType: The type of the component to get.
    /// - Returns: The component requested or null if the component isn't in the archetype.
    /// - Throws: If there is an error getting the component, possibly a decoding error.
    func getComponent<T>(rowId: LECSRowId, componentId: LECSComponentId, componentType: T.Type) throws -> T?

    /// Follows the add edge of the archetype to the archetype that contains the component.
    /// - Parameter id: The id of the component to add.
    /// - Returns: The archetype with the current archetype's components and the new component if the archetype exists.
    func addComponent(_ id: LECSComponentId) -> LECSArchetype?

    /// Follows the remove edge of the archetype to the archetype that doesn't contain the component.
    /// - Parameter id: The id of the component to remove.
    /// - Returns: The archetype with the current archetype's components minus the removed component if the archetype exists.
    func removeComponent(_ id: LECSComponentId) -> LECSArchetype?

    /// Sets an add edge on the archetype so it knows where to go when a component is added.
    /// - Parameters:
    ///   - id: The id of the component to set as an add edge.
    ///   - archetype: The archetype to go to when the component is added.
    func setAddEdge(_ id: LECSComponentId, _ archetype: LECSArchetype)

    /// Sets a remove edge on the archetype so it knows where to go when a component is removed.
    /// - Parameters:
    ///   - id: The id of the component to set as a remove edge.
    ///   - archetype: The archetype to go to when the component is removed.
    func setRemoveEdge(_ id: LECSComponentId, _ archetype: LECSArchetype)
}

class LECSArchetypeFixedSize: LECSArchetype {
    let id: LECSArchetypeId
    let type: LECSType
    private var table: LECSTable
    let columns: LECSColumns
    private var edges: [LECSComponentId:ArchetypeEdge] = [:]

    //TODO: Think about ways to reduce the number of arguments on here
    /// Creates a new Archetype to hold the specified type.
    /// - Parameters:
    ///   - id: The id of the Archetype, generated externally, must be unique.
    ///   - type: The component ids stored in the archetype. Determines the order the components are stored.
    ///   - columns: The types of the components stored in the archetype. Must match the order of the component ids in type.
    ///   - size: The maximum number of records the archetype can hold.
    init(
        id: LECSArchetypeId,
        type: LECSType,
        columns: LECSColumns,
        size: LECSSize
    ) {
        self.id = id
        self.type = type
        self.columns = columns

        // total of all the strides of the components
        let elementSize = columns.reduce(0) { $0 + MemoryLayout.stride(ofValue: $1) }

        self.table = LECSTable(elementSize: elementSize, size: size)
    }

    /// Creates a new archetype of the specified type, allowing the table to be explicitly provided.
    /// - Parameters:
    ///   - id: The id of the Archetype, generated externally, must be unique.
    ///   - type: The component ids stored in the archetype. Determines the order the components are stored.
    ///   - columns: The types of the components stored in the archetype. Must match the order of the component ids in type.
    ///   - table: The table to store the components in.
    init(id: LECSArchetypeId, type: LECSType, columns: LECSColumns, table: LECSTable) {
        self.id = id
        self.type = type
        self.columns = columns
        self.table = table
    }

    func insert(_ values: LECSRow) throws -> LECSRowId {
        let encoder = LECSRowEncoder(table.elementSize)
        let data = try encoder.encode(values)
        return table.insert(data)
    }

    func read(_ rowId: LECSRowId) throws -> LECSRow? {
        guard let data = table.read(rowId) else {
            return nil
        }
        let decoder = LECSRowDecoder(data)
        return try decoder.decode(types: columns)
    }

    func remove(_ rowId: LECSRowId) throws -> LECSRow? {
        let row = try read(rowId)
        table.remove(rowId)
        return row
    }

    func hasComponent(_ component: LECSComponentId) -> Bool {
        type.contains(component) 
    }

    func getComponent<T>(rowId: LECSRowId, componentId: LECSComponentId, componentType: T.Type) throws -> T? {
        var component: T? = nil

        if let componentIndex = type.firstIndex(of: componentId), let row = try read(rowId) {
            component = row[componentIndex] as? T
        }

        return component
    }

    func addComponent(_ id: LECSComponentId) -> LECSArchetype? {
        edges[id]?.add
    }

    func removeComponent(_ id: LECSComponentId) -> LECSArchetype? {
        edges[id]?.remove
    }

    func setAddEdge(_ id: LECSComponentId, _ archetype: LECSArchetype) {
        if var edge = edges[id] {
            edge.add = archetype
        } else {
            edges[id] = ArchetypeEdge(add: archetype)
        }
    }

    func setRemoveEdge(_ id: LECSComponentId, _ archetype: LECSArchetype) {
        if var edge = edges[id] {
            edge.remove = archetype
        } else {
            edges[id] = ArchetypeEdge(remove: archetype)
        }
    }
}

struct LECSTable {
    private var rows: Data
    fileprivate let elementSize: LECSSize
    fileprivate let size: LECSSize
    private (set) var count: LECSSize

    private var removed: Set<LECSRowId> = []

    init(elementSize: LECSSize, size: LECSSize) {
        self.elementSize = elementSize
        self.size = size

        rows = Data(count: elementSize * size)
        count = 0
    }

    mutating func insert(_ values: Data) -> LECSRowId {
        let row = emptyRow()
        let offset = offset(row)
        rows.replaceSubrange(offset..<(offset + elementSize), with: values)
        return row
    }

    func read(_ rowId: LECSRowId) -> Data? {
        guard !removed.contains(rowId) else {
            return nil
        }

        return rows.subdata(in: (rowId * elementSize)..<(rowId * elementSize + elementSize))
    }

    mutating func remove(_ id: Int)  {
        removed.insert(id)
    }

    mutating private func emptyRow() -> LECSRowId {
        //TODO: reuse rows that have been removed
        let row = count
        count += 1
        return row
    }

    private func offset(_ row: LECSRowId) -> Int {
        row * elementSize
    }
}

struct ArchetypeEdge {
    var add: LECSArchetype? = nil
    var remove: LECSArchetype? = nil
}
