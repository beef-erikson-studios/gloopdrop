//
//  AdMobHelper.swift
//  gloopdrop
//
//  Created by Tammy Coron on 1/24/2020.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//
//  Further edits by Troy Martin on 12/14/2024.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import Foundation
import GoogleMobileAds


/// AdMob configuration struct for times / Ad ID's.
struct AdMobHelper {
    static let bannerAdDisplayTime: TimeInterval = 30
    static let bannerAdID = "ca-app-pub-3940256099942544/2435281174"
}


// MARK: - DELEGATE EXTENSIONS

/* ############################################################ */
/*             ADMOB DELEGATE FUNCTIONS STARTS HERE             */
/* ############################################################ */

extension GameViewController : GADBannerViewDelegate {
  
    // MARK: - GADBannerViewDelegate: Ad Request Lifecycle Notifications
  
    /// Tells the delegate an ad request loaded an ad.
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "60fbaa1eb87bfad1db0f6003e966ab34" ]

        // Set the ad banner view and animate for fade
        adBannerView = bannerView
        UIView.animate(withDuration: 0.5,
                       animations: {[weak self] in self?.adBannerView.alpha = 1.0})
        
        // Auto-hide banner
        Timer.scheduledTimer(timeInterval: AdMobHelper.bannerAdDisplayTime,
                             target: self,
                             selector: #selector(hideBanner(_:)),
                             userInfo: bannerView, repeats: false)
        
    }
  
    /// Tells the delegate an ad request failed.
    func bannerView(_ bannerView: GADBannerView,
                    didFailToReceiveAdWithError error: any Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
  
    // MARK: - GADBannerViewDelegate: Click-Time Lifecycle Notifications
  
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
  
    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
  
    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
}


extension GameViewController: GADFullScreenContentDelegate {
  
    // MARK: - GADRewardedAdDelegate: Lifecycle Notifications
  
    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received: \(reward.type) | amount: \(reward.amount).")
    }
  
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
    }
  
    /// Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad dismissed.")
    }
  
    /// Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
        print("Rewarded ad failed to present.")
    }
}


// MARK: - GAMEVIEWCONTROLLER EXTENSION FUNCTIONS

// TODO: Make sure this works.
// Hold the reusable view (only available for this file)
fileprivate var _adBannerView = GADBannerView(adSize: GADAdSizeFluid)

extension GameViewController {
    
    // Properties
    var adBannerView: GADBannerView {
        get {
            return _adBannerView
        }
        set(newValue) {
            _adBannerView = newValue
        }
    }
    
    /// Set up the banner ads.
    ///
    /// - Parameters:
    ///   - id: String of the adBannerView
    func setupBannerAdsWith(id: String) {
        
        // Set up banner ads and view
        adBannerView.adUnitID = id
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        // Add the banner view to the view
        addBannerViewToView(adBannerView)
        
        // Start serving ads
        startServingAds(after: AdMobHelper.bannerAdDisplayTime)
    }
    
    /// Adds the banner ad view to the current view.
    ///
    /// - Parameters:
    ///   - bannerView: The GADBannerView to add; this will be the ad.
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Starts serving ads with a scheduled timer.
    ///
    /// - Parameters:
    ///   - seconds: Number of seconds to display the ad.
    func startServingAds(after seconds: TimeInterval) {
        // Start serving banner ads after ## seconds.
        Timer.scheduledTimer(timeInterval: seconds, target: self,
                             selector: #selector(requestAds(_:)),
                             userInfo: adBannerView, repeats: false)
        print("start serving ads...")
    }
    
    /// Starts serving banner ads.
    ///
    /// - Parameters;
    ///   - timer: Timer for how long to display an ad.
    @objc func requestAds(_ timer: Timer) {
        
        // Display ad
        let bannerView = timer.userInfo as? GADBannerView
        let request = GADRequest()
        bannerView?.load(request)
        
        print("Loaded request \(request)")
        
        // End timer
        timer.invalidate()
    }
    
    /// Hides the banner displaying the ads.
    ///
    /// - Parameters:
    ///   - timer: How long to hide the ad.
    @objc func hideBanner(_ timer: Timer) {
        
        // Hide the ad banner
        let bannerView = timer.userInfo as! GADBannerView
        UIView.animate(withDuration: 0.5) {
            bannerView.alpha = 0.0
        }
        
        // End timer
        timer.invalidate()
    }
}
