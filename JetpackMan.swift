//
//  Character.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/30/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import SpriteKit

class JetpackMan: SKSpriteNode {
    
    func walk() {
        let textures = [
            SKTexture(imageNamed: "walk-1"),
            SKTexture(imageNamed: "walk-2"),
            SKTexture(imageNamed: "walk-3"),
            SKTexture(imageNamed: "walk-4")
        ]
        let walkCycle = SKAction.animateWithTextures(textures, timePerFrame: 0.2)
        let walkForever = SKAction.repeatActionForever(walkCycle)
        runAction(walkForever)
    }
    
    func run() {
        
    }
    
    func fly() {
        
    }
}
