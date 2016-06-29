//
//  GameScene.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit


// This struct holds all physics categories
// Using a struct like this allows you to give each category a name.
// These physics categoriesa are also used to generate collisions 
// and contacts in an easy and intuitive way, see comments below.
struct PhysicsCategory {
    static let None:    UInt32 = 0          // 0000
    static let Player:  UInt32 = 0b1        // 0001
    static let Block:   UInt32 = 0b10       // 0010
    static let Coin:    UInt32 = 0b100      // 0100
    static let Floor:   UInt32 = 0b1000     // 1000
}

// NOTE: Remember a Category is a type of thing in your physics world. This example 
// contains Blocks (red), Coins (Yellow), Ground (Brown), and Player (Orange)

// Contacts generate a message in didBeginContact that occurs when two objects make contact. 
// Contacts do produce a physical results, in other words when a contact occurs between two 
// objects it doen't mean that they bounce or show a physical interaction. 

// Collisions generate physical interaction between objects. If you want an object to
// bounce or bump or push another object it's collision mask must include the category 
// of object it will interact with. 

// In this example the Player object only collides with the ground. Block and Coin objects 
// will pass through the player. The Player object generates contact messages when it 
// makes contact with Coins, and Blocks.

// Look through the comments in the code blocks below to see how the PhysicsCategory 
// is used to set contacts and collisions.




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground: SKSpriteNode!
    var groundHeight: CGFloat = 40
    var player: SKSpriteNode!
    var touchDown = false
    var jetpackEmitter: SKEmitterNode!
    
    
    
    // Creates blocks
    
    func createBlock() {
        let blockSize = CGSize(width: 40, height: 40)
        let block = SKSpriteNode(color: UIColor.redColor(), size: blockSize)
        
        block.position.x = view!.frame.size.width
        block.position.y = groundHeight + blockSize.height / 2
        
        block.physicsBody = SKPhysicsBody(rectangleOfSize: blockSize)
        block.physicsBody?.dynamic = false
        block.physicsBody?.affectedByGravity = false
        
        // in this game blocks may only contact a player, collide with nothing.
        block.physicsBody?.categoryBitMask    = PhysicsCategory.Block
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        block.physicsBody?.collisionBitMask   = PhysicsCategory.None
        
        let moveAction = SKAction.moveToX(0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let blockAction = SKAction.sequence([moveAction, removeAction])
        block.runAction(blockAction)
        
        addChild(block)
    }
    
    
    
    // Maks coins
    
    func makeCoin() {
        let coinSize = CGSize(width: 20, height: 20)
        let coin = SKSpriteNode(color: UIColor.yellowColor(), size: coinSize)
        
        coin.position.x = view!.frame.size.width
        coin.position.y = CGFloat(arc4random() % 14 * 20 + 100)
        
        coin.physicsBody = SKPhysicsBody(rectangleOfSize: coinSize)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.dynamic = false
        
        // Coins collide with nothing and contact only with players
        coin.physicsBody?.categoryBitMask   = PhysicsCategory.Coin
        coin.physicsBody?.collisionBitMask  = PhysicsCategory.None
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        let moveAction = SKAction.moveToX(0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let blockAction = SKAction.sequence([moveAction, removeAction])
        coin.runAction(blockAction)
        
        addChild(coin)
    }
    
    
    
    
    // The ground
    
    func setupGround() {
        let groundSize = CGSize(width: view!.frame.width, height: 40)
        ground = SKSpriteNode(color: UIColor.brownColor(), size: groundSize)
        ground.position.x = groundSize.width / 2
        ground.position.y = groundSize.height / 2
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: groundSize)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.affectedByGravity = false
        
        // The ground will contact nothing, and collide with the player.
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.None
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
        
        addChild(ground)
    }
    
    
    
    // The Player
    
    func setupPlayer() {
        let playerSize = CGSize(width: 20, height: 40)
        player = SKSpriteNode(color: UIColor.orangeColor(), size: playerSize)
        
        player.position.x = view!.frame.size.width / 2
        player.position.y = groundHeight / 2 + playerSize.height / 2
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: playerSize)
        player.physicsBody?.allowsRotation = false
        
        // The player will collide with the Floor, and make contact with Blocksm and Coins
        // The | means or. Think of the contactTestBitMask below as saying "Block or Coin"
        player.physicsBody?.categoryBitMask     = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask    = PhysicsCategory.Floor
        player.physicsBody?.contactTestBitMask  = PhysicsCategory.Block | PhysicsCategory.Coin
        
        jetpackEmitter = SKEmitterNode(fileNamed: "JetpackEmitter")
        jetpackEmitter.targetNode = self
        jetpackEmitter.zPosition = -1
        jetpackEmitter.numParticlesToEmit = 1 // Shut off the emitter
        player.addChild(jetpackEmitter)
        
        addChild(player)
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Setup the ground object 
        
        setupGround()
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        physicsWorld.contactDelegate = self
        
        // Setup the player object
        
        setupPlayer()
        
        // Mark: Make Blocks
        
        let makeBlock = SKAction.runBlock {
            self.createBlock()
        }
        
        let delay = SKAction.waitForDuration(2)
        let sequence = SKAction.sequence([delay, makeBlock])
        let repeatBlocks = SKAction.repeatActionForever(sequence)
        runAction(repeatBlocks)
        
        // MARK: Make Coins
        
        let makeCoin = SKAction.runBlock {
            self.makeCoin()
        }
        
        let coinDelay = SKAction.waitForDuration(2)
        let coinSequence = SKAction.sequence([coinDelay, makeCoin])
        let repeatCoins = SKAction.repeatActionForever(coinSequence)
        runAction(repeatCoins)
    }
    
    
    
    
    // MARK: Physics Contact
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Block | PhysicsCategory.Player {
            print("Player Hit Block")
        } else if collision == PhysicsCategory.Coin | PhysicsCategory.Player {
            print("Player Hit Coin")
        }
    }
    
    
    
    
    
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        touchDown = true
        // Start emitting particles
        jetpackEmitter.numParticlesToEmit = 0 // Emit endless particles
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ends */
        touchDown = false
        // Stop emitting particles
        jetpackEmitter.numParticlesToEmit = 1 // Emit maximum of 1 particle
    }
    
    
    
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if touchDown {
            let upVector = CGVector(dx: 0, dy: 75)
            // Push the player up
            player.physicsBody?.applyForce(upVector)
        }
    }
}
