//
//  LECSId.swift
//
//
//  Created by David Kanenwisher on 4/11/24.
//

import Foundation

public struct LECSId: LECSComponent {
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
}
