//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

public struct LECSId: LECSComponent, Codable {
    var id: UInt

    public init() {
        self.id = 0
    }

    public init(id: UInt) {
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decode(UInt.self)
    }
}
