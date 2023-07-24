//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation
import simd

public struct LECSPosition2d: LECSComponent, Codable {
    public var x: Float
    public var y: Float

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(x)
        try container.encode(y)
    }

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        x = try container.decode(Float.self)
        y = try container.decode(Float.self)
    }
}

public struct LECSVelocity2d: LECSComponent, Codable {
    public var velocity: SIMD2<Float>

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(velocity.x)
        try container.encode(velocity.y)
    }

    public init(x: Float, y: Float) {
        velocity = SIMD2<Float>(x, y)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let x = try container.decode(Float.self)
        let y = try container.decode(Float.self)
        velocity = SIMD2<Float>(x, y)
    }
}
