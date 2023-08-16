# lecs-swift

[![Swift](https://github.com/prufrock/lecs-swift/actions/workflows/test.yaml/badge.svg)](https://github.com/prufrock/lecs-swift/actions/workflows/test.yaml)

A little Entity-Component-System library in Swift.

## Features

* Create entities with any combination of components.
* Create components from your own types(structs highly recommended).
* Quickly update or select entitites with systems using component based queries.

### Future Features

* Object wrapper for entities
* Dynamically resizing archetypes
* System scheduler
* Query optimizations
* Thread safety
* Spatial queries

## References:
* [Building an ECS #1: Where are my Entities and Components](https://ajmmertens.medium.com/building-an-ecs-1-where-are-my-entities-and-components-63d07c7da742)
* [Building an ECS #2: Archetypes and Vectorization](https://ajmmertens.medium.com/building-an-ecs-2-archetypes-and-vectorization-fe21690805f9)
* [Building Games in ECS with Entity Relationships
](https://ajmmertens.medium.com/building-games-in-ecs-with-entity-relationships-657275ba2c6c)
* [flecs](https://www.flecs.dev/flecs/index.html)
* [Game Progamming Patterns - Component](http://gameprogrammingpatterns.com/component.html)
* [Game Programming Patterns - Data Localilty](http://gameprogrammingpatterns.com/data-locality.html)

## Basic Usage

When you get started with lecs-swift the first thing to do is to add the package to you project and then add the package to the target.

Now that the target has lecs-swift you can start using it. You'll want to import the project into the file you need it in:
```swift
import lecs_swift
```

From here you create the World and configure how big it can get via the `archetypeSize` argument:

```swift
let world: LECSWorld = LECSWorldFixedSize(archetypeSize: 2000)
```

Now that we have a World lets prepare it for action by adding a system:
```swift
let updatePosition = world.addSystem("updatePosition", selector: [LECSPosition2d.self, LECSVelocity2d.self]) { world, row, columns in
  var position = row.component(at: 0, columns, LECSPosition2d.self)
  var velocity = row.component(at: 0, columns, LECSVelocity2d.self)
  position.x = position.x + velocity.x
  position.y = position.y + velocity.y

  return [position, velocity]
}
```

You have a World, it has a System ready to move something. It's time to put an entity in it:

```swift
let grasshopper = world.createEntity("grasshopper")
```

Now in classic ECS style you should add some properties to the grasshopper by adding a component or two:
```swift
world.addComponent(grasshopper, LECSPosition2d(x: 1.0, y: 2.0))
world.addComponent(grasshopper, LECSVelocity2d(x: 0.1, y: 0.5))
```

All the pieces are in place, lets start it up:
```swift
/// assuming we're in your game's update method
world.process(system: updatePosition)
```

With that our grasshopper position should have changed. Now we can show our eager users:
```swift
/// inside your rendering code
let positions: [simd_float4x4] = []
world.select([LECSPosition2d.self]) { (world, row, columns) in
  var position = row.component(at: 0, columns, LECSPosition2d.self)
  positions.append[simd_float4x4.translate(x: position.x, y: position.y)]
}
```

There you have it! Now you can use lecs-swift to move a thing and show a thing! :horse_racing:
