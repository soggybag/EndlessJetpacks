//
//  GameScene.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit
import GameplayKit



// TODO: Invent interesting Obstacles...
//  1) Ground with a pit
//  2) Narrow passage like Flappy Bird
//  3) Missiles
//  4) Breakable items that contain treasure...

// TODO: Add State machine...

// ------------------------------------------------





class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Set the forward speed of the player
    var playerSpeed: CGFloat = 40
    // Set the width of the landscape section
    let sceneNodeWidth: CGFloat = 800
    
    // Height of ground
    var groundHeight: CGFloat = 40
    
    var gameState: GKStateMachine
    
    // Set the size for various objects
    let playerSize = CGSize(width: 20, height: 40)
    let blockSize = CGSize(width: 40, height: 40)
    let coinSize = CGSize(width: 20, height: 20)
    let enemySize = CGSize(width: 40, height: 40)
    let bulletSize = CGSize(width: 10, height: 10)
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var ground: SKSpriteNode!
    
    var touchDown = false
    
    var player: SKSpriteNode!
    var jetpackEmitter: SKEmitterNode!
    var scoreLabel: SKLabelNode!
    var distanceLabel: SKLabelNode!
    var sceneCamera: SKCameraNode!
    
    var sceneNodes = [BackgroundSection]()
    
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
    
    
    
    
    // MARK: - Init 
    
    override init() {
        gameState = GKStateMachine(states: [])
        super.init()
        
        
    }
    
    override init(size: CGSize) {
        gameState = GKStateMachine(states: [])
        super.init(size: size)
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
        gameState = GKStateMachine(states: [])
    }
    
    
    
    // MARK: Generate Obstacles 
    
    func generateObstacle(_ node: SKNode) {
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
    
    func createBlock(_ node: SKNode) {
        let block = SKSpriteNode(color: UIColor.red, size: blockSize)
        
        block.position.x = CGFloat(arc4random() % UInt32(sceneNodeWidth - 100)) + 50
        block.position.y = groundHeight + blockSize.height / 2
        
        block.physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        block.physicsBody!.isDynamic = false
        block.physicsBody!.affectedByGravity = false
        
        // In this game blocks generate a contact with a player, they produce a collision.
        block.physicsBody!.categoryBitMask    = PhysicsCategory.Block
        block.physicsBody!.collisionBitMask   = PhysicsCategory.None
        block.physicsBody!.contactTestBitMask = PhysicsCategory.Player
        
        node.addChild(block)
    }
    
    
    // MARK: Create Enemy
    
    func createEnemy(_ node: SKNode) {
        let enemy = SKSpriteNode(color: UIColor.blue, size: enemySize)
        let y = CGFloat(arc4random() % UInt32(view!.frame.height - groundHeight - enemySize.height)) + groundHeight + enemySize.height
        enemy.position = CGPoint(x: view!.frame.size.width, y: y)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemySize)
        enemy.physicsBody!.affectedByGravity = false
        
        // Enemy objects generate a contact with player and bullet. They do not collide.
        enemy.physicsBody!.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategory.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Bullet
        
        node.addChild(enemy)
    }
    
    
    
    // MARK: Fire Bullet
    
    func fireBullet() {
        let bullet = SKSpriteNode(color: UIColor.cyan, size: bulletSize)
        
        bullet.position = player.position
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bulletSize)
        bullet.physicsBody!.isDynamic = false
        bullet.physicsBody!.allowsRotation = false
        bullet.physicsBody!.affectedByGravity = false
        
        // Bullets contact enemys, but do not collide.
        bullet.physicsBody!.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategory.Enemy
        
        let dx = view!.frame.width / 2 + 100
        let moveAction = SKAction.moveBy(x: dx, y: 0, duration: 1)
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
        
        addChild(bullet)
    }
    
    
    
    // MARK: Create Coin
    
    func getCoin() -> SKSpriteNode {
        let coin = SKSpriteNode(color: UIColor.yellow, size: coinSize)
        coin.name = "coin"
        return coin
    }
    
    func makeCoin() -> SKSpriteNode {
        let coin = getCoin()
        
        coin.position.x = view!.frame.size.width
        coin.position.y = CGFloat(arc4random() % 14) * coinSize.width + 100
        
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.isDynamic = false
        
        // Coins collide with nothing and contact only with players.
        coin.physicsBody?.categoryBitMask   = PhysicsCategory.Coin
        coin.physicsBody?.collisionBitMask  = PhysicsCategory.None
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        return coin
    }
    
    
    
    
    // MARK: Create Ground
    
    func makeGround() -> SKSpriteNode {
        let groundSize = CGSize(width: sceneNodeWidth, height: groundHeight)
        ground = SKSpriteNode(color: UIColor.brown, size: groundSize)
        ground.position.x = groundSize.width / 2
        ground.position.y = groundSize.height / 2
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: groundSize)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        
        // The ground will contact nothing, and collide with the player.
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Floor
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
        
        return ground
    }
    
    
    func makeCeiling() {
        let ceilingSize = CGSize(width: sceneNodeWidth, height: 40)
        let ceiling = SKSpriteNode(color: UIColor.purple, size: ceilingSize)
        
        ceiling.position.y = view!.frame.height / 2
        
        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceilingSize)
        ceiling.physicsBody!.isDynamic = false
        ceiling.physicsBody!.affectedByGravity = false
        
        // The ceiling collides with the player and does not generate contact.
        ceiling.physicsBody!.categoryBitMask = PhysicsCategory.Ceiling
        ceiling.physicsBody!.collisionBitMask = PhysicsCategory.Player
        ceiling.physicsBody!.contactTestBitMask = PhysicsCategory.None
        
        sceneCamera.addChild(ceiling)
    }
    
    
    
    // MARK: Create Player
    
    func setupPlayer() {
        player = SKSpriteNode(color: UIColor.orange, size: playerSize)
        
        player.position.x = view!.frame.size.width / 2
        player.position.y = groundHeight / 2 + playerSize.height / 2
        
        player.physicsBody = SKPhysicsBody(rectangleOf: playerSize)
        player.physicsBody?.allowsRotation = false
        
        player.physicsBody?.affectedByGravity = true // ****
        
        // The player will collide with the Floor, and make contact with Blocks, Enemies and Coins
        // The | means or. Think of the contactTestBitMask below as saying "Block or Coin or Enemy"
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
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        
        scoreLabel.position.x = screenWidth / -2 + 10
        scoreLabel.position.y = screenHeight / 2 - 10
        
        scoreLabel.text = "0"
        
        sceneCamera.addChild(scoreLabel)
        
        distanceLabel = SKLabelNode(fontNamed: "Edit Undo BRK")
        distanceLabel.fontSize = 27
        distanceLabel.verticalAlignmentMode = .top
        distanceLabel.horizontalAlignmentMode = .left
        
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
        let makeCoin = SKAction.run {
            self.makeCoin()
        }
        
        let coinDelay = SKAction.wait(forDuration: 2)
        let coinSequence = SKAction.sequence([coinDelay, makeCoin])
        let repeatCoins = SKAction.repeatForever(coinSequence)
        run(repeatCoins)
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
    
    func addContentToSceneNode(_ node: SKNode) {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 0.5)
        let size = CGSize(width: sceneNodeWidth, height: view!.frame.height)
        let sprite = SKSpriteNode(color: color, size: size)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        node.childNode(withName: "contentNode")?.removeAllChildren()
        node.childNode(withName: "contentNode")?.addChild(sprite)
        generateObstacle(node.childNode(withName: "contentNode")!)
        
    }
    
    
    
    
    // ------------------------------------------------
    
    // MARK: Did move to view
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        screenWidth = view.frame.width
        screenHeight = view.frame.height
        
        let backgroundSize = CGSize(width: sceneNodeWidth, height: screenHeight)
        let background_1 = BackgroundSection(size: backgroundSize)
        let background_2 = BackgroundSection(size: backgroundSize)
        sceneNodes = [background_1, background_2]
            
        
        
        
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
    
    func makeCoinPoofAtPoint(_ point: CGPoint) {
        if let poof = SKEmitterNode(fileNamed: "CoinPoof") {
            addChild(poof)
            poof.position = point
            let wait = SKAction.wait(forDuration: 1)
            let remove = SKAction.removeFromParent()
            let seq = SKAction.sequence([wait, remove])
            poof.run(seq)
        }
    }
    
    
    func makeEnemyDestroyedExplosion(_ point: CGPoint) {
        if let explosion = SKEmitterNode(fileNamed: "EnemyDestroyed") {
            addChild(explosion)
            explosion.position = point
            let wait = SKAction.wait(forDuration: 1)
            let removeExplosion = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, removeExplosion]))
        }
    }
    
    
    
    // ------------------------------------------------
    
    /** Removes physics objects that have been marked for removal. */
    
    // MARK: Physics Contact
    
    var physicsObjectsToRemove = [SKNode]()
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Block | PhysicsCategory.Player {
            // MARK: Block hits Player
            print("*** Player Hit Block ***")
            if contact.collisionImpulse > 50 {
                print("destroy block")
            }
        
        } else if collision == PhysicsCategory.Coin | PhysicsCategory.Player {
            // MARK: Player hits Coin
            print("*** Player Hit Coin ***")
            coinsCollected += 1
            
            let poofPoint = self.convert(contact.bodyA.node!.position,
                                              from: contact.bodyA.node!.parent!)
            
            if contact.bodyA.node!.name == "coin" {
                makeCoinPoofAtPoint(poofPoint)
                physicsObjectsToRemove.append(contact.bodyA.node!)
                
            } else {
                makeCoinPoofAtPoint(poofPoint)
                physicsObjectsToRemove.append(contact.bodyB.node!)
                
            }
            
        } else if collision == PhysicsCategory.Player | PhysicsCategory.Floor {
            // MARK: Player hit Floor
            print("*** Player hit floor ***")
            
            
        } else if collision == PhysicsCategory.Player | PhysicsCategory.Enemy {
            // MARK: Player hits Enemy
            print("*** Player hit Enemy ***")
            
            
        } else if collision == PhysicsCategory.Bullet | PhysicsCategory.Enemy {
            // MARK: Bullet hits Enemy
            print("*** Bullet hits Enemy ***")
            
            let poofPoint = self.convert(contact.bodyA.node!.position,
                                              from: contact.bodyA.node!.parent!)
            
            if contact.bodyA.node!.name == "bullet" {
                makeEnemyDestroyedExplosion(poofPoint)
            } else {
                makeEnemyDestroyedExplosion(poofPoint)
            }
            physicsObjectsToRemove.append(contact.bodyA.node!)
            physicsObjectsToRemove.append(contact.bodyB.node!)
        }
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        //
    }
    
    
    override func didSimulatePhysics() {
        for node in physicsObjectsToRemove {
            node.removeFromParent()
        }
    }


    
    
    // ------------------------------------------------
    
    // MARK: Touch events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        // Check all touches
        for touch in touches {
            let location = touch.location(in: sceneCamera)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch ends */
        // Check all touches
        for touch in touches {
            let location = touch.location(in: sceneCamera)
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
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        var deltaTime: CFTimeInterval = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if deltaTime > 1 {
            deltaTime = 1 / 60
            lastUpdateTime = currentTime
        }
        
        player.position.x += playerSpeed * CGFloat(deltaTime)
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
    
    /** 
    
    Call this on update to check the position of sceneNodes.
     When a scene Node has passed the camera view to the left
     this method moves that scene to the right of the current 
     scene in view.
    
    */
    
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
    
    /** 
     
    Returns a node containing a random block of coin objects.
     
    */
    
    func makeCoinBlock(_ node: SKNode) {
        let blockNode = SKNode()
        blockNode.name = "coinblock"
        
        let block = getCoinBlock()
        
        for row in 0 ..< block.count {
            for col in 0 ..< block[row].count {
                if block[row][col] == 1 {
                    let coin = makeCoin()
                    coin.position = CGPoint(x: 21 * CGFloat(col) + (21/2), y: 21 * CGFloat(-row) - (21/2))
                    blockNode.addChild(coin)
                }
            }
        }
        
        let w = CGFloat(block[0].count) * 21
        let h = CGFloat(block.count) * 21
        let rangeY = view!.frame.height - groundHeight - 20 - h
        let y = CGFloat(arc4random() % UInt32(rangeY)) + h + groundHeight
        
        /*
        let testSprite = SKSpriteNode(color: UIColor(white: 1, alpha: 0.5), size: CGSize(width: w, height: h))
        testSprite.anchorPoint = CGPoint(x: 0, y: 1)
        blockNode.addChild(testSprite)
        */
        
        blockNode.position.x = 100
        blockNode.position.y = y
        
        node.addChild(blockNode)
    }
}



extension GameScene {
    
    /**
     Returns a random array describing a block of coins.
    */
    
    func getCoinBlock() -> [[Int]] {
        
        // These nested arrays describe the position of coins displayed in blocks. 
        // A 1 places a coin, a 0 is empty.
        // (Need to separate these nested arrays to avoid long compile times...)
        
        let a = [
            [1,1,1,0,0,0],
            [0,1,1,1,0,0],
            [0,0,1,1,1,0],
            [0,0,0,1,1,1]
        ]
        
        let b = [
            [0,0,0,1,0,0,0],
            [0,0,1,1,1,0,0],
            [0,1,1,1,1,1,0],
            [1,1,1,1,1,1,1],
            [0,1,1,1,1,1,0],
            [0,0,1,1,1,0,0],
            [0,0,0,1,0,0,0]
        ]
        
        let c = [
            [1,1,0,0,0,1,1],
            [1,1,1,0,1,1,1],
            [1,1,1,1,1,1,1],
            [1,1,1,1,1,1,1],
            [1,1,0,1,0,1,1],
            [1,1,0,0,0,1,1]
        ]
        
        let d = [
            [1,1,1,1,1,1,0,0,0,0,0,0],
            [0,0,0,0,0,0,1,1,1,1,1,1]
        ]
    
        let blocks = [a, b, c, d]
        
        return blocks[Int(arc4random() % UInt32(blocks.count))]
    }
}


