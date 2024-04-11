//
//  LECSName.swift
//
//
//  Created by David Kanenwisher on 4/6/24.
//

import Foundation

public struct LECSName: LECSComponent {
    var name: String

    public init() {
        name = "i am the default name"
    }

    public init(_ name: String) {
        self.name = name
    }
}
