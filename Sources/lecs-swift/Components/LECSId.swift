//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

public struct LECSId: LECSComponent {
    public var id: UInt

    public init() {
        self.id = 0
    }

    public init(id: UInt) {
        self.id = id
    }
}
