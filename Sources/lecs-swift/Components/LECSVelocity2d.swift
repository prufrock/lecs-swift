//
//  LECSVelocity2d.swift
//  
//
//  Created by David Kanenwisher on 8/5/23.
//

import Foundation
import simd

public struct LECSVelocity2d: LECSComponent, Codable {
    public var velocity: SIMD2<Float>

    public init() {
        velocity = SIMD2<Float>(0, 0)
    }

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
