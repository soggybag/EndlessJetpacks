//
//  Ground.swift
//  EndlessJetpacks
//
//  Created by mitchell hudson on 8/2/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import SpriteKit

class Ground: SKNode {
  
  
  // MARK: - Properties
  
  let groundNodes = [SKSpriteNode(), SKSpriteNode(), SKSpriteNode()]
  let size: CGSize
  
  
  
  
  // MARK: - Init
  
  init(size: CGSize) {
    
    self.size = size
    
    super.init()
    
    setupGround()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  
  // MARK: - Setup
  
  func setupGround() {
    for i in 0 ..< groundNodes.count {
      let node = groundNodes[i]
      addChild(node)
      node.color = UIColor.brown
      let w = size.width / 3
      let h = size.height
      node.size = CGSize(width: w, height: h)
      node.position = CGPoint(x: CGFloat(i) * 3 + w / 2, y: h / 2)
      
    }
  }
  
  
  
  // MARK: - Utility
  
  
  
}














