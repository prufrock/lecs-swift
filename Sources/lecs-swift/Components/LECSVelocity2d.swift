//
//  File.swift
//  
//
//  Created by David Kanenwisher on 3/30/24.
//

import Foundation

public struct LECSVelocity2d: LECSComponent, Equatable {
    public init() {
        velocity = SIMD2<Float>(x: 0, y: 0)
    }

    public init(x: Float, y: Float) {
        velocity = SIMD2<Float>(x: x, y: y)
    }

    public init(_ velocity: SIMD2<Float>) {
        self.velocity = velocity
    }

    public var x: Float {
        velocity.x
    }
    public var y: Float {
        velocity.y
    }
    public var velocity: SIMD2<Float>
}
