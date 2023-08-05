//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation
import simd

public struct LECSPosition2d: LECSComponent, Codable {
    public var position: SIMD2<Float>

    public var x: Float {
        get {
            position.x
        }
        set(value) {
            position.x = value
        }
    }

    public var y: Float {
        get {
            position.y
        }
        set(value) {
            position.y = value
        }
    }

    public init() {
        position = SIMD2<Float>(0, 0)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(position.x)
        try container.encode(position.y)
    }

    public init(x: Float, y: Float) {
        position = SIMD2<Float>(x, y)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        position = SIMD2<Float>(
            try container.decode(Float.self),
            try container.decode(Float.self)
        )
    }
}
