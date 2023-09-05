//
//  LECSVelocity2d.swift
//  
//
//  Created by David Kanenwisher on 8/5/23.
//

import Foundation
import simd

public struct LECSVelocity2d: LECSComponent {
    public var velocity: SIMD2<Float>
    public var x: Float {
        get {
            velocity.x
        }
    }
    public var y: Float {
        get {
            velocity.y
        }
    }

    public init() {
        velocity = SIMD2<Float>(0, 0)
    }

    public init(x: Float, y: Float) {
        velocity = SIMD2<Float>(x, y)
    }

    public init(_ velocity: SIMD2<Float>) {
        self.velocity = velocity
    }
}
