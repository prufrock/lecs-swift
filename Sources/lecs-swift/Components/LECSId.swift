//
//  LECSId.swift
//
//
//  Created by David Kanenwisher on 4/11/24.
//

import Foundation

public struct LECSId: LECSComponent, Equatable {
    public var id: UInt

    public init() {
        id = 0
    }

    public init(id: UInt) {
        self.id = id
    }

    public init(_ id: UInt) {
        self.id = id
    }

    public static func == (lhs: LECSId, rhs: LECSId) -> Bool {
        return lhs.id == rhs.id
    }
}
