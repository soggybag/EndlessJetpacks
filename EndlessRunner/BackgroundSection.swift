//
//  BackgroundSection.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 8/3/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import SpriteKit

class BackgroundSection: SKNode {
    let size: CGSize
    let ground: Ground
    let groundHeight: CGFloat = 40
    
    // MARK: - Init
    
    init(size: CGSize) {
        self.size = size
        self.ground = Ground(size: CGSize(width: size.width, height: groundHeight))
        
        super.init()
        
        let hue = CGFloat(arc4random() % 1000) / 1000
        let test = SKSpriteNode(color: UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1) , size: size)
        addChild(test)
        test.zPosition = -1
        
        test.anchorPoint.x = 0
        test.anchorPoint.y = 0
        
        
        setupGround()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: - Setup
    
    func setupGround() {
        addChild(ground)
        // ground.position.y = groundHeight / 2
        ground.zPosition = PostitionZ.Ground
    }
}
