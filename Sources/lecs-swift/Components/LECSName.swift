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
        if (name.count > 15) {
            fatalError("I'm lazy so this blows up if you make LECSName larger than 15 characters.")
        }
        self.name = name
    }
}
