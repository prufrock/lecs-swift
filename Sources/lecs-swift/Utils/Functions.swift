//
//  Functions.swift
//  
//
//  Created by David Kanenwisher on 7/9/23.
//

import Foundation

extension Dictionary where Value: RangeReplaceableCollection {
    /// Appends the value to the collection at the key if the collection exists otherwise creates the collection and
    /// inserts the collection at the key with the new value.
    /// - Parameters:
    ///   - value: The value to append.
    ///   - key: The key to update the value at.
    /// - Returns: Void
    mutating func updateCollection(_ value: Value.Element, forKey key: Key) -> Void {
        var collection = self[key] ?? Value()
        collection.append(value)
        self[key] = collection
    }
}

extension Collection {
    @inlinable public var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Array where Element: Comparable {
    /// Combine both arrays into pairs and sort the result based on the first element.
    /// - Parameter other: The array of elements to combine with.
    /// - Returns: An array of pairs.
    func aligned<T>(with other: Array<T>) -> [(Element, T)] {
        let aligned = zip(self, other)
        return aligned.sorted { $0.0 < $1.0 }
    }
}

extension Array where Element == (LECSComponentId, LECSComponent) {
    func type() -> [LECSComponentId] {
        return self.map {$0.0}
    }

    func row() -> [LECSComponent] {
        return self.map {$0.1}
    }
}

extension Array where Element == LECSComponent {
    func update(_ pairs: [(LECSArchetypeColumn, LECSComponent)]) -> LECSRow {
        var newArray = self
        pairs.forEach { column, component in
            newArray[column.col] = component
        }

        return newArray
    }
}
