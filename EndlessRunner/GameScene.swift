//
//  GameScene.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit
import GameplayKit


// TODO: Add obstacles to sceneNode and cycle scene nodes.
// TODO: Switch motion to parent node using convert to point
// TODO: !? Player moves forward. Objects are created in ahead. Camera follows Player...
// TODO: Keep track of distance travelled as points
// TODO: Add State machine...



// ------------------------------------------------

// MARK: Physics Category

// This struct holds all physics categories
// Using a struct like this allows you to give each category a name.
// These physics categoriesa are also used to generate collisions 
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
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var ground: SKSpriteNode!
    var groundHeight: CGFloat = 40
    var touchDown = false
    
    var player: SKSpriteNode!
    var jetpackEmitter: SKEmitterNode!
    var scoreLabel: SKLabelNode!
    var distanceLabel: SKLabelNode!
    var sceneCamera: SKCameraNode!
    
    let sceneNodes = [SKNode(), SKNode()]
    let sceneNodeWidth: CGFloat = 800
    
    let playerSize = CGSize(width: 20, height: 40)
    let blockSize = CGSize(width: 40, height: 40)
    let coinSize = CGSize(width: 20, height: 20)
    let enemySize = CGSize(width: 40, height: 40)
    let bulletSize = CGSize(width: 10, height: 10)
    
    var coinsCollected: Int = 0 {
        didSet {
            scoreLabel.text = "\(coinsCollected)"
        }
    }
    
    var distanceTravelled: Int = 0 {
        didSet {
            distanceLabel.text = "\(distanceTravelled)"
        }
    }
    
    
    
    
    
    
    // MARK: Generate Obstacles 
    
    func generateObstacle(node: SKNode) {
        let n = arc4random() % 3
        switch n {
        case 0:
            makeCoinBlock(node)
            
        case 1:
            createBlock(node)
            
        case 2:
            createEnemy(node)
            
        default:
            print("???")
            
        }
    }
    
    
    
    
    // MARK: Creates blocks
    
    func createBlock(node: SKNode) {
        let block = SKSpriteNode(color: UIColor.redColor(), size: blockSize)
        
        block.position.x = CGFloat(arc4random() % UInt32(sceneNodeWidth - 100)) + 50
        block.position.y = groundHeight + blockSize.height / 2
        
        block.physicsBody = SKPhysicsBody(rectangleOfSize: blockSize)
        block.physicsBody!.dynamic = false
        block.physicsBody!.affectedByGravity = false
        
        // in this game blocks may only contact a player, collide with nothing.
        block.physicsBody!.categoryBitMask    = PhysicsCategory.Block
        block.physicsBody!.collisionBitMask   = PhysicsCategory.None
        block.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        node.addChild(block)
    }
    
    
    // MARK: Create Enemy
    
    func createEnemy(node: SKNode) {
        let enemy = SKSpriteNode(color: UIColor.blueColor(), size: enemySize)
        let y = CGFloat(arc4random() % UInt32(view!.frame.height - groundHeight - enemySize.height)) + groundHeight + enemySize.height
        enemy.position = CGPoint(x: view!.frame.size.width, y: y)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemySize)
        enemy.physicsBody!.affectedByGravity = false
        
        enemy.physicsBody!.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategory.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Bullet
        
        node.addChild(enemy)
    }
    
    
    
    // MARK: Fire Bullet
    
    func fireBullet() {
        let bullet = SKSpriteNode(color: UIColor.cyanColor(), size: bulletSize)
        
        bullet.position = player.position
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bulletSize)
        bullet.physicsBody!.dynamic = false
        bullet.physicsBody!.allowsRotation = false
        bullet.physicsBody!.affectedByGravity = false
        
        bullet.physicsBody!.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategory.Enemy
        
        let dx = view!.frame.width / 2 + 100
        let moveAction = SKAction.moveByX(dx, y: 0, duration: 1)
        let removeAction = SKAction.removeFromParent()
        bullet.runAction(SKAction.sequence([moveAction, removeAction]))
        
        addChild(bullet)
    }
    
    
    
    // MARK: Create Coin
    
    func getCoin() -> SKSpriteNode {
        let coin = SKSpriteNode(color: UIColor.yellowColor(), size: coinSize)
        coin.name = "coin"
        return coin
    }
    
    func makeCoin() -> SKSpriteNode {
        let coin = getCoin()
        
        coin.position.x = view!.frame.size.width
        coin.position.y = CGFloat(arc4random() % 14) * coinSize.width + 100
        
        coin.physicsBody = SKPhysicsBody(rectangleOfSize: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.dynamic = false
        
        // Coins collide with nothing and contact only with players
        coin.physicsBody?.categoryBitMask   = PhysicsCategory.Coin
        coin.physicsBody?.collisionBitMask  = PhysicsCategory.None
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        return coin
    }
    
    
    
    
    // MARK: Create Ground
    
    func makeGround() -> SKSpriteNode {
        let groundSize = CGSize(width: sceneNodeWidth, height: groundHeight)
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
        
        return ground
    }
    
    
    func makeCeiling() {
        let ceilingSize = CGSize(width: sceneNodeWidth, height: 40)
        let ceiling = SKSpriteNode(color: UIColor.purpleColor(), size: ceilingSize)
        
        ceiling.position.y = view!.frame.height / 2
        
        ceiling.physicsBody = SKPhysicsBody(rectangleOfSize: ceilingSize)
        ceiling.physicsBody!.dynamic = false
        ceiling.physicsBody!.affectedByGravity = false
        
        ceiling.physicsBody!.categoryBitMask = PhysicsCategory.Ceiling
        ceiling.physicsBody!.collisionBitMask = PhysicsCategory.Player
        ceiling.physicsBody!.contactTestBitMask = PhysicsCategory.None
        
        sceneCamera.addChild(ceiling)
    }
    
    
    
    // MARK: Create Player
    
    func setupPlayer() {
        player = SKSpriteNode(color: UIColor.orangeColor(), size: playerSize)
        
        player.position.x = view!.frame.size.width / 2
        player.position.y = groundHeight / 2 + playerSize.height / 2
        
        player.physicsBody = SKPhysicsBody(rectangleOfSize: playerSize)
        player.physicsBody?.allowsRotation = false
        
        player.physicsBody?.affectedByGravity = true // ****
        
        // The player will collide with the Floor, and make contact with Blocksm and Coins
        // The | means or. Think of the contactTestBitMask below as saying "Block or Coin"
        player.physicsBody?.categoryBitMask     = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask    = PhysicsCategory.Floor | PhysicsCategory.Ceiling
        player.physicsBody?.contactTestBitMask  = PhysicsCategory.Block | PhysicsCategory.Coin | PhysicsCategory.Enemy
        
        player.physicsBody?.linearDamping = 0.55
        player.physicsBody?.mass = 0.01
        
        jetpackEmitter = SKEmitterNode(fileNamed: "JetpackEmitter")
        jetpackEmitter.targetNode = self
        jetpackEmitter.zPosition = -1
        jetpackEmitter.numParticlesToEmit = 1 // Shut off the emitter
        player.addChild(jetpackEmitter)
        
        addChild(player)
    }
    
    
    
    
    // MARK: Setup Label
    
    func setupLabels() {
        scoreLabel = SKLabelNode(fontNamed: "Edit Undo BRK")
        scoreLabel.fontSize = 27
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.horizontalAlignmentMode = .Left
        
        scoreLabel.position.x = screenWidth / -2 + 10
        scoreLabel.position.y = screenHeight / 2 - 10
        
        scoreLabel.text = "0"
        
        sceneCamera.addChild(scoreLabel)
        
        distanceLabel = SKLabelNode(fontNamed: "Edit Undo BRK")
        distanceLabel.fontSize = 27
        distanceLabel.verticalAlignmentMode = .Top
        distanceLabel.horizontalAlignmentMode = .Left
        
        distanceLabel.position.x = screenWidth / -2 + 10
        distanceLabel.position.y = scoreLabel.position.y - 30
        distanceLabel.text = "0"
        sceneCamera.addChild(distanceLabel)
    }
    
    
    // MARK: Setup Jetpackman

    func setupJetpackman() {
        let jetpackMan = JetpackMan(texture: SKTexture(imageNamed: "walk-1"))
        jetpackMan.walk()
        
        jetpackMan.position.x = 100
        jetpackMan.position.y = 100
        addChild(jetpackMan)
    }
    
    
    // MARK: Make coins
    
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
    
    
    
    
    // MARK: Setup Camera
    
    func setupCamera() {
        sceneCamera = SKCameraNode()
        addChild(sceneCamera)
        camera = sceneCamera
        sceneCamera.position.x = screenWidth / 2
        sceneCamera.position.y = screenHeight / 2
    }
    
    
    
    // MARK: Setup Scene Nodes 
    
    func setupSceneNodes() {
        for i in 0 ..< sceneNodes.count {
            sceneNodes[i].position.x = sceneNodeWidth * CGFloat(i)
            addChild(sceneNodes[i])
            let contentNode = SKNode()
            contentNode.name = "contentNode"
            sceneNodes[i].addChild(contentNode)
            sceneNodes[i].addChild(makeGround())
        }
        
        addContentToSceneNode(sceneNodes[1])
    }
    
    func addContentToSceneNode(node: SKNode) {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 0.5)
        let size = CGSize(width: sceneNodeWidth, height: view!.frame.height)
        let sprite = SKSpriteNode(color: color, size: size)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        node.childNodeWithName("contentNode")?.removeAllChildren()
        node.childNodeWithName("contentNode")?.addChild(sprite)
        generateObstacle(node.childNodeWithName("contentNode")!)
        
    }
    
    
    
    
    // ------------------------------------------------
    
    // MARK: Did move to view
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        
        // physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.5)
        
        // Setup Jetpackman
        setupJetpackman()
        
        // Setup scene nodes
        setupSceneNodes()
        
        // Setup the player object
        setupPlayer()
        
        // Setup Camera
        setupCamera()
        
        // Setup Ceiling
        makeCeiling()
        
        // Setup score label (must come after camera!)
        setupLabels()
        
        // Testing convertPoint
        // var p = ground.position
        // print("Ground Position")
        // print(p)
        // print("Ground to camera")
        // print(ground.convertPoint(p, toNode: sceneCamera))
        // print("Back to scene")
        // print(self.convertPoint(p, fromNode: self))
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
    
    
    func makeEnemyDestroyedExplosion(point: CGPoint) {
        if let explosion = SKEmitterNode(fileNamed: "EnemyDestroyed") {
            addChild(explosion)
            explosion.position = point
            let wait = SKAction.waitForDuration(1)
            let removeExplosion = SKAction.removeFromParent()
            explosion.runAction(SKAction.sequence([wait, removeExplosion]))
        }
    }
    
    
    
    // ------------------------------------------------
    
    /** Removes physics objects that have been marked for removal. */
    
    // MARK: Physics Contact
    
    var physicsObjectsToRemove = [SKNode]()
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Block | PhysicsCategory.Player {
            // MARK: Block hits Player
            // print("Player Hit Block")
            if contact.collisionImpulse > 50 {
                print("destroy block")
            }
        
        } else if collision == PhysicsCategory.Coin | PhysicsCategory.Player {
            // MARK: Player hits Coin
            // print("Player Hit Coin")
            coinsCollected += 1
            
            let poofPoint = self.convertPoint(contact.bodyA.node!.position,
                                              fromNode: contact.bodyA.node!.parent!)
            
            if contact.bodyA.node!.name == "coin" {
                makeCoinPoofAtPoint(poofPoint)
                physicsObjectsToRemove.append(contact.bodyA.node!)
                
            } else {
                makeCoinPoofAtPoint(poofPoint)
                physicsObjectsToRemove.append(contact.bodyB.node!)
                
            }
            
        } else if collision == PhysicsCategory.Player | PhysicsCategory.Floor {
            // MARK: Player hit Floor
            // print("**** Player hit floor ****")
            
            
        } else if collision == PhysicsCategory.Player | PhysicsCategory.Enemy {
            // MARK: Player hits Enemy
            // print("**** Player hit Enemy ****")
            
            
        } else if collision == PhysicsCategory.Bullet | PhysicsCategory.Enemy {
            // MARK: Bullet hits Enemy
            print("**** Bullet hits Enemy ****")
            
            let poofPoint = self.convertPoint(contact.bodyA.node!.position,
                                              fromNode: contact.bodyA.node!.parent!)
            
            if contact.bodyA.node!.name == "bullet" {
                makeEnemyDestroyedExplosion(poofPoint)
            } else {
                makeEnemyDestroyedExplosion(poofPoint)
            }
            physicsObjectsToRemove.append(contact.bodyA.node!)
            physicsObjectsToRemove.append(contact.bodyB.node!)
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
            let location = touch.locationInNode(sceneCamera)
            if location.x < 0 {
                // This touch was on the left side of the screen
                touchDown = true
                // Start emitting particles
                jetpackEmitter.numParticlesToEmit = 0 // Emit endless particles
            } else {
                // This touch was on the right side of the screen
                fireBullet()
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ends */
        // Check all touches
        for touch in touches {
            let location = touch.locationInNode(sceneCamera)
            if location.x < 0 {
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
    var lastUpdateTime: CFTimeInterval = 0
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        var deltaTime: CFTimeInterval = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if deltaTime > 1 {
            deltaTime = 1 / 60
            lastUpdateTime = currentTime
        }
        
        player.position.x += 40 * CGFloat(deltaTime)
        distanceTravelled = Int(player.position.x / 30)
        
        sceneCamera.position.x = player.position.x
        
        scrollSceneNodes()
        
        // TODO: Use deltaTime here
        
        if touchDown {
            let upVector = CGVector(dx: 0, dy: 22)
            // Push the player up
            player.physicsBody?.applyForce(upVector)
        }
    }
}


extension GameScene {
    // Check position of nodes as camera moves
    func scrollSceneNodes() {
        for node in sceneNodes {
            let x = node.position.x - sceneCamera.position.x
            if x < -(sceneNodeWidth + view!.frame.width / 2) {
                node.position.x += sceneNodeWidth * 2
                addContentToSceneNode(node)
            }
        }
    }
}




extension GameScene {
    func makeCoinBlock(node: SKNode) {
        let blockNode = SKNode()
        blockNode.name = "coinblock"
        
        let blocks = [[[1,1,0,0,0,1,1],
                       [1,1,1,0,1,1,1],
                       [1,1,1,1,1,1,1],
                       [1,1,1,1,1,1,1],
                       [1,1,0,1,0,1,1],
                       [1,1,0,0,0,1,1]],
                      
                      [[1,1,1,0,0,0],
                       [0,1,1,1,0,0],
                       [0,0,1,1,1,0],
                       [0,0,0,1,1,1]],
                      
                      [ [0,0,0,1,0,0,0],
                        [0,0,1,1,1,0,0],
                        [0,1,1,1,1,1,0],
                        [1,1,1,1,1,1,1],
                        [0,1,1,1,1,1,0],
                        [0,0,1,1,1,0,0],
                        [0,0,0,1,0,0,0]]
                      ]
        
        let block = blocks[Int(arc4random() % UInt32(blocks.count))]
        
        for row in 0 ..< block.count {
            for col in 0 ..< block[row].count {
                if block[row][col] == 1 {
                    let coin = makeCoin()
                    coin.position = CGPoint(x: 21 * CGFloat(col), y: 21 * CGFloat(-row))
                    blockNode.addChild(coin)
                }
            }
        }
        
        
        let h = CGFloat(block.count) * 21
        let y = CGFloat(arc4random() % UInt32(view!.frame.height - h - groundHeight - 21)) + h + groundHeight
        
        blockNode.position.x = 100
        blockNode.position.y = y
        
        node.addChild(blockNode)
    }
}


