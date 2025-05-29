//
//  LECSWorldObserver.swift
//  lecs-swift
//
//  Created by David Kanenwisher on 5/23/25.
//

public protocol LECSWorldObserver {
    func entityCreated(id: LECSEntityId, name: String)

    func entityDeleted(id: LECSEntityId, name: String)

    func componentAdded<T: LECSComponent>(id: LECSEntityId, component: T)

    func componentRemoved(id: LECSEntityId, component: any LECSComponent.Type)
}
