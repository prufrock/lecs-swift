//
//  File.swift
//  
//
//  Created by David Kanenwisher on 6/10/23.
//

import Foundation

public protocol LECSComponent {
    init()
}

/// The Id of a LECSComponent
struct LECSComponentId {
    let id: Int
}
