//
//  File.swift
//  
//
//  Created by David Kanenwisher on 3/30/24.
//

import Foundation

struct LECSVelocity: LECSComponent {
    init() {
        x = 0
        y = 0
    }

    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    var x: Float
    var y: Float
}
