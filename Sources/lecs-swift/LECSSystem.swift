//
//  File.swift
//  
//
//  Created by David Kanenwisher on 7/14/23.
//

import Foundation

struct LECSSystem {
    let name: String
    let selector: [LECSComponentId]
    let lambda: (LECSWorld, [LECSComponent], [Int]) -> [LECSComponent]
}
