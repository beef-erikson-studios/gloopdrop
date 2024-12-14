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
            
            // Add banner ads to view
            addBannerViewToView(bannerView)
            
            // Set the ad unit ID and view controller that contains the GADBannerView.
            bannerView.adUnitID = AdMobHelper.bannerAdID
            bannerView.rootViewController = self

            bannerView.load(GADRequest())
        }
        
        func addBannerViewToView(_ bannerView: GADBannerView) {
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            // This example doesn't give width or height constraints, as the provided
            // ad size gives the banner an intrinsic content size to size the view.
            view.addConstraints(
              [NSLayoutConstraint(item: bannerView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: view.safeAreaLayoutGuide,
                                  attribute: .bottom,
                                  multiplier: 1,
                                  constant: 0),
              NSLayoutConstraint(item: bannerView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
              ])
          }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
