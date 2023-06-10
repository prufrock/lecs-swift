//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

struct LECSId: Codable {
    var id: UInt

    init(id: UInt) {
        self.id = id
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(id)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        id = try container.decode(UInt.self)
    }
}
