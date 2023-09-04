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

    public init() {
        velocity = SIMD2<Float>(0, 0)
    }

    public init(x: Float, y: Float) {
        velocity = SIMD2<Float>(x, y)
    }
}
