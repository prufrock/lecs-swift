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
