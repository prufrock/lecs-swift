//
//  AnyMetaTypeWrapper.swift
//  
//
//  Created by David Kanenwisher on 6/24/23.
//

import Foundation

/**
 Makes it possible to hash Types.
 Helpful post about it on Swift forums: https://forums.swift.org/t/make-types-hashable/38837/3
 */
struct MetatypeWrapper {
    let metatype: Any.Type

    init(_ metatype: Any.Type) {
        self.metatype = metatype
    }
}

extension MetatypeWrapper: Equatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.metatype == rhs.metatype
    }
}

extension MetatypeWrapper: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(metatype))
    }
}

extension Dictionary {
    subscript(_ key: Any.Type) -> Value? where Key == MetatypeWrapper {
        get { self[MetatypeWrapper(key)] }
        _modify { yield &self[MetatypeWrapper(key)] }
    }
}

extension Set {
    @discardableResult
    mutating func insert(_ newMember: Any.Type) -> (inserted: Bool, memberAfterInsert: Element) where Element == MetatypeWrapper {
        insert(MetatypeWrapper(newMember))
    }

    func contains(_ member: Any.Type) -> Bool where Element == MetatypeWrapper {
        contains(MetatypeWrapper(member))
    }
}
