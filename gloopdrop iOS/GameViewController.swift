//
//  GameViewController.swift
//  gloopdrop iOS
//
//  Created by Troy Martin on 6/15/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the view
        if let view = self.view as! SKView? {
            
            // Create the scene
            let scene = GameScene(size: CGSize(width: 1336, height: 1024))

            // Set the scale mode to fill the entire area
            scene.scaleMode = .aspectFill
            
            // Set the background color
            scene.backgroundColor = UIColor(red: 105/255,
                                            green: 157/255,
                                            blue: 181/255,
                                            alpha: 1.0)

            // Present the scene
            view.presentScene(scene)
            
            // Debugging
            view.ignoresSiblingOrder = false
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
