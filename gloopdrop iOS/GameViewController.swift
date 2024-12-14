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

    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view width for ads
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        let adaptiveSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)

        bannerView = GADBannerView(adSize: adaptiveSize)
        
        // Add test machine(s).
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "60fbaa1eb87bfad1db0f6003e966ab34" ]
        
        // TODO: - FIX TIMER SO IT CONTINUOUSLY REINSTANTIATES BANNER.
        // Add banner ads to view
        //addBannerViewToView(bannerView)
        setupBannerAdsWith(id: AdMobHelper.bannerAdID, banner: bannerView)
        
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
