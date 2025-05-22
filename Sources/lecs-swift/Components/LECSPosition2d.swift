//
//  Position.swift
//
//
//  Created by David Kanenwisher on 3/28/24.
//

import Foundation

public struct LECSPosition2d: LECSComponent, Equatable {
    public var position: SIMD2<Float>

    public init() {
        position = SIMD2<Float>(x: 0, y: 0)
    }

    public init(x: Float, y: Float) {
        self.position = SIMD2<Float>(x: x, y: y)
    }

    public init(_ position: SIMD2<Float>) {
        self.position = position
    }

    public var x: Float {
        set {
            position.x = newValue
        }
        get {
            position.x
        }
    }
    public var y: Float {
        set {
            position.y = newValue
        }
        get {
            position.y
        }
    }
}

extension LECSPosition2d {
    public var position3d: SIMD3<Float> {
        SIMD3<Float>(x: position.x, y: position.y, z: 0)
    }
}
