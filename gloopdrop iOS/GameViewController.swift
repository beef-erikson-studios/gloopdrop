//
//  GameViewController.swift
//  gloopdrop iOS
//
//  Created by Troy Martin on 6/15/24.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add test machine(s).
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "60fbaa1eb87bfad1db0f6003e966ab34" ]
        
        // Add banner ads to view
        setupBannerAdsWith(id: AdMobHelper.bannerAdID, view: view)
        
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
