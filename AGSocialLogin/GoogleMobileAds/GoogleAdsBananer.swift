//
//  GoogleAdsBananer.swift
//  ReparaciónDeCelulares
//
//  Created by thirdeyes Infotech Pvt Ltd on 22/02/18.
//  Copyright © 2018 3eyes Infotech Pvt Ltd. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GoneVisible

class GoogleAdsBananer: GADBannerView, GADBannerViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultInti()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultInti()
    }
    
    func defaultInti(){
        adUnitID = "ca-app-pub-0772677822264077/1142649724"
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9a" ]
        load(request)
        rootViewController = self.agParentViewController
        delegate = self
        self.backgroundColor = UIColor.white
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.visible()
    }
    
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        if error.code == GADErrorCode.internalError.rawValue {
            
        }
        self.gone()
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        self.visible()
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}

extension UIView {
    
    var agParentViewController: UIViewController {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController ?? UIApplication.shared.keyWindow!.rootViewController!
    }
}
