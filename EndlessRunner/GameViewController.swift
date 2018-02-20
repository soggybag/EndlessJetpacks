//
//  GameViewController.swift
//  EndlessRunner
//
//  Created by mitchell hudson on 6/28/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scene = GameScene(size: view.frame.size)
    // Configure the view.
    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    // skView.showsPhysics = true
    
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .aspectFill
    
    skView.presentScene(scene)
  }
  
  //    override func shouldAutorotate() -> Bool {
  //        return true
  //    }
  
  //    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
  //      if UIDevice.currentDevice.userInterfaceIdiom == .Phone {
  //        return .allButUpsideDown
  //        } else {
  //        return .all
  //        }
  //    }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  //    override func prefersStatusBarHidden() -> Bool {
  //        return true
  //    }
}
