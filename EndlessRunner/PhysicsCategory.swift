//
//  PhysicsCategory.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 8/2/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import Foundation

// MARK: Physics Category

// This struct holds all physics categories
// Using a struct like this allows you to give each category a name.
// These physics categories are also used to generate collisions
// and contacts in an easy and intuitive way, see comments below.
struct PhysicsCategory {
    static let None:    UInt32 = 0          // 0000000
    static let Player:  UInt32 = 0b1        // 0000001    00001
    static let Block:   UInt32 = 0b10       // 0000010
    static let Coin:    UInt32 = 0b100      // 0000100    00100
    static let Floor:   UInt32 = 0b1000     // 0001000    00101
    static let Enemy:   UInt32 = 0b10000    // 0010000
    static let Bullet:  UInt32 = 0b100000   // 0100000
    static let Ceiling: UInt32 = 0b1000000  // 1000000
    // 00000000000000000000000000000000
}

// categoryBitMask -
// A category is a type of thing in your physics world. This example
// contains Blocks (red), Coins (Yellow), Ground (Brown), and Player (Orange)
// Each different type of thing needs a category. You can have up to 32 categories.

// contactTestBitMask -
// Contact mask generate a message in didBeginContact/didEndContact that occurs when two objects
// make contact. Contacts do NOT produce a physical results, in other words when a contact occurs
// between two objects it doen't mean that they bounce or show a physical interaction.

// collisionBitMask -
// Collisions generate physical interaction between objects. If you want an object to
// bounce or bump or push another object it's collision mask must include the category
// of object it will collide with.

// In this example the Player object only collides with the ground. Block and Coin objects
// will pass through the player. The Player object generates contact messages when it
// makes contact with Coins, and Blocks (even though they don't generate a collision).

// Look through the comments in the code blocks below to see how the PhysicsCategory
// is used to set contacts and collisions.
