//
//  GameViewController.swift
//  FlappyBird
//
//  Created by Kagen Zhao on 2016/9/29.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            if view.scene == nil {
                let scale = view.bounds.size.height / view.bounds.size.width
                let scene = GameScene(size: CGSize(width: 320, height: 320 * scale))
                scene.scaleMode = .aspectFill
                view.ignoresSiblingOrder = true
                view.showsFPS = true
                view.showsNodeCount = true
                view.presentScene(scene)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
