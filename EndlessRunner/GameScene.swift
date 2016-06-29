//
//  GameScene.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit



struct PhysicsCategory {
    static let None:    UInt32 = 0
    static let Player:  UInt32 = 0b1
    static let Block:   UInt32 = 0b10
    static let Coin:    UInt32 = 0b100
    static let Floor:   UInt32 = 0b1000
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ground: SKSpriteNode!
    var groundHeight: CGFloat = 40
    var player: SKSpriteNode!
    var touchDown = false
    var jetpackEmitter: SKEmitterNode!
    
    func createBlock() {
        let blockSize = CGSize(width: 40, height: 40)
        let block = SKSpriteNode(color: UIColor.redColor(), size: blockSize)
        
        block.position.x = view!.frame.size.width
        block.position.y = groundHeight + blockSize.height / 2
        
        block.physicsBody = SKPhysicsBody(rectangleOfSize: blockSize)
        block.physicsBody?.dynamic = false
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.categoryBitMask    = PhysicsCategory.Block
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        block.physicsBody?.collisionBitMask   = PhysicsCategory.None
        
        let moveAction = SKAction.moveToX(0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let blockAction = SKAction.sequence([moveAction, removeAction])
        block.runAction(blockAction)
        
        addChild(block)
    }
    
    
    
    func makeCoin() {
        let coinSize = CGSize(width: 20, height: 20)
        let coin = SKSpriteNode(color: UIColor.yellowColor(), size: coinSize)
        
        coin.position.x = view!.frame.size.width
        coin.position.y = CGFloat(arc4random() % 14 * 20 + 100)
        
        coin.physicsBody = SKPhysicsBody(rectangleOfSize: coinSize)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.dynamic = false
        coin.physicsBody?.categoryBitMask   = PhysicsCategory.Coin
        coin.physicsBody?.collisionBitMask  = PhysicsCategory.None
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        let moveAction = SKAction.moveToX(0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        let blockAction = SKAction.sequence([moveAction, removeAction])
        coin.runAction(blockAction)
        
        addChild(coin)
    }
    
    
    
    func setupGround() {
        let groundSize = CGSize(width: view!.frame.width, height: 40)
        ground = SKSpriteNode(color: UIColor.brownColor(), size: groundSize)
        ground.position.x = groundSize.width / 2
        ground.position.y = groundSize.height / 2
        
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: groundSize)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        
        addChild(ground)
    }
    
    
    func setupPlayer() {
        let playerSize = CGSize(width: 20, height: 40)
        player = SKSpriteNode(color: UIColor.orangeColor(), size: playerSize)
        
        player.position.x = view!.frame.size.width / 2
        player.position.y = groundHeight / 2 + playerSize.height / 2
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: playerSize)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask     = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask    = PhysicsCategory.Floor
        player.physicsBody?.contactTestBitMask  = PhysicsCategory.Block | PhysicsCategory.Coin
        
        jetpackEmitter = SKEmitterNode(fileNamed: "JetpackEmitter")
        jetpackEmitter.targetNode = self
        jetpackEmitter.zPosition = -1
        player.addChild(jetpackEmitter)
        
        addChild(player)
    }
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        setupGround()
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        physicsWorld.contactDelegate = self
        
        //
        
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
