//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

public struct LECSName: LECSComponent, Hashable {
    public var name: String

    public init() {
        self.name = ""
    }

    public init(name: String) {
        self.name = name
    }
}
