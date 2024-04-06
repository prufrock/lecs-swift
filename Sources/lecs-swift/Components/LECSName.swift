//
//  LECSName.swift
//
//
//  Created by David Kanenwisher on 4/6/24.
//

import Foundation

struct LECSName: LECSComponent {
    var name: String

    init() {
        name = "i am the default name"
    }

    init(_ name: String) {
        self.name = name
    }
}
