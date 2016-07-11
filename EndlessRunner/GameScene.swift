//
//  GameScene.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit
import GameplayKit




// ------------------------------------------------

// MARK: Physics Category

// This struct holds all physics categories
// Using a struct like this allows you to give each category a name.
// These physics categoriesa are also used to generate collisions 
// and contacts in an easy and intuitive way, see comments below.
struct PhysicsCategory {
    static let None:    UInt32 = 0          // 000000
    static let Player:  UInt32 = 0b1        // 000001
    static let Block:   UInt32 = 0b10       // 000010
    static let Coin:    UInt32 = 0b100      // 000100
    static let Floor:   UInt32 = 0b1000     // 001000
    static let PowerUp: UInt32 = 0b10000    // 010000
    static let Ball:    UInt32 = 0b100000   // 100000
    // 00000000000000000000000000000000     // 000101
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
    
    var screenWidth: CGFloat! = nil
    
    var ground: SKSpriteNode!
    var groundHeight: CGFloat = 40
    var player: SKSpriteNode!
    var touchDown = false
    var jetpackEmitter: SKEmitterNode!
    var scoreLabel: SKLabelNode!
    
    var coinsCollected: Int = 0 {
        didSet {
            scoreLabel.text = "\(coinsCollected)"
        }
    }
    
    
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
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
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
        
        player.physicsBody?.linearDamping = 0.21
        
        jetpackEmitter = SKEmitterNode(fileNamed: "JetpackEmitter")
        jetpackEmitter.targetNode = self
        jetpackEmitter.zPosition = -1
        jetpackEmitter.numParticlesToEmit = 1 // Shut off the emitter
        player.addChild(jetpackEmitter)
        
        addChild(player)
    }
    
    
    
    
    
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Edit Undo BRK")
        scoreLabel.fontSize = 27
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.horizontalAlignmentMode = .Left
        
        scoreLabel.position.x = 10
        scoreLabel.position.y = view!.frame.height - 10
        
        scoreLabel.text = "0"
        
        addChild(scoreLabel)
    }
    
    

    func setupJetpackman() {
        let jetpackMan = JetpackMan(texture: SKTexture(imageNamed: "walk-1"))
        jetpackMan.walk()
        
        jetpackMan.position.x = 100
        jetpackMan.position.y = 100
        addChild(jetpackMan)
    }
    
    
    
    func startblockGenerator() {
        // Mark: Make Blocks
        let makeBlock = SKAction.runBlock {
            self.createBlock()
        }
        
        let delay = SKAction.waitForDuration(2)
        let sequence = SKAction.sequence([delay, makeBlock])
        let repeatBlocks = SKAction.repeatActionForever(sequence)
        runAction(repeatBlocks)
    }
    
    
    func startMakingCoins() {
        // MARK: Make Coins
        let makeCoin = SKAction.runBlock {
            self.makeCoin()
        }
        
        let coinDelay = SKAction.waitForDuration(2)
        let coinSequence = SKAction.sequence([coinDelay, makeCoin])
        let repeatCoins = SKAction.repeatActionForever(coinSequence)
        runAction(repeatCoins)
    }
    
    
    
    
    
    // ------------------------------------------------
    
    // MARK: Did move to view
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // Get the numberic values for Physics categories
        // print(PhysicsCategory.None)
        // print(PhysicsCategory.Block)
        // print(PhysicsCategory.Coin)
        // print(PhysicsCategory.Block | PhysicsCategory.Coin)
        
        screenWidth = view.frame.width / 2
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.5)
        
        // Setup Jetpackman
        setupJetpackman()
        
        // Setup the ground object
        setupGround()
        
        // Setup the player object
        setupPlayer()
        
        // MARK: Setup score label
        setupScoreLabel()
        
        // Start making blocks
        startblockGenerator()
        
        // Start making coins
        startMakingCoins()
    }
    
    
    
    
    // ------------------------------------------------
    
    /** Makes a particle effect at the position of a coin that is picked up. */
    
    func makeCoinPoofAtPoint(point: CGPoint) {
        if let poof = SKEmitterNode(fileNamed: "CoinPoof") {
            addChild(poof)
            poof.position = point
            let wait = SKAction.waitForDuration(1)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([wait, remove])
            poof.runAction(seq)
        }
    }
    
    
    
    
    
    // ------------------------------------------------
    
    /** Removes physics objects that have been marked for removal. */
    
    // MARK: Physics Contact
    
    var physicsObjectsToRemove = [SKNode]()
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Block | PhysicsCategory.Player {
            print("Player Hit Block")
        } else if collision == PhysicsCategory.Coin | PhysicsCategory.Player {
            print("Player Hit Coin")
            coinsCollected += 1
            
            if contact.bodyA.node!.name == "coin" {
                makeCoinPoofAtPoint(contact.bodyA.node!.position)
                physicsObjectsToRemove.append(contact.bodyA.node!)
            } else {
                makeCoinPoofAtPoint(contact.bodyB.node!.position)
                physicsObjectsToRemove.append(contact.bodyB.node!)
            }
        } else if collision == PhysicsCategory.Player | PhysicsCategory.Floor {
            print("**** Player hit floor ****")
        }
    }
    
    
    override func didSimulatePhysics() {
        for node in physicsObjectsToRemove {
            node.removeFromParent()
        }
    }


    
    
    // ------------------------------------------------
    
    // MARK: Touch events
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        // Check all touches
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.x < screenWidth {
                // This touch was on the left side of the screen
                touchDown = true
                // Start emitting particles
                jetpackEmitter.numParticlesToEmit = 0 // Emit endless particles
            } else {
                // This touch was on the right side of the screen
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ends */
        // Check all touches
        for touch in touches {
            let location = touch.locationInNode(self)
            if location.x < screenWidth {
                // This touch was on the left side of the screen
                touchDown = false
                // Stop emitting particles
                jetpackEmitter.numParticlesToEmit = 1 // Emit maximum of 1 particle
            } else {
                // This touch was on the right side of the screen
                
            }
        }
    }
    
    
    
    // ------------------------------------------------
    
    // MARK: Update
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if touchDown {
            let upVector = CGVector(dx: 0, dy: 75)
            // Push the player up
            player.physicsBody?.applyForce(upVector)
        }
    }
    
    
}
