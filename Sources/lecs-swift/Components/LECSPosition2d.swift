//
//  Position.swift
//
//
//  Created by David Kanenwisher on 3/28/24.
//

import Foundation

public struct LECSPosition2d: LECSComponent, Equatable {
    public init() {
        x = 0
        y = 0
    }

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public var x: Float
    public var y: Float
}
