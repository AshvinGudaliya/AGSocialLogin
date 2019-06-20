//
//  GoogleAdsInterstitial.swift
//  ReparaciónDeCelulares
//
//  Created by thirdeyes Infotech Pvt Ltd on 22/02/18.
//  Copyright © 2018 3eyes Infotech Pvt Ltd. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GoogleAdsInterstitial: GADInterstitial ,GADInterstitialDelegate {
    
    var rootViewController: UIViewController
    required init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(adUnitID: "ca-app-pub-0772677822264077/3577241374")
        GADMobileAds.configure(withApplicationID: "ca-app-pub-0772677822264077~7174184538")
        delegate = self
        
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9a" ]
        load(request)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        self.present(fromRootViewController: self.rootViewController)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //interstitial.addGoogleAdsBanner(self)
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
