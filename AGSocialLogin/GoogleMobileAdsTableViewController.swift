//
//  GoogleMobileAdsTableViewController.swift
//  AGSocialLogin
//
//  Created by thirdeyes Infotech Pvt Ltd on 26/02/18.
//  Copyright © 2018 AshvinGudaliya. All rights reserved.
//

import UIKit

enum AGGoogleProductType: String{
    case Login = "Login"
    case GoogleAdsBananer = "Google Bananer Ads"
    case GoogleAdsInterstitial = "Google Interstitial Ads"
}

class GoogleMobileAdsTableViewController: UITableViewController {

    var menuOption: [AGGoogleProductType] = [.Login, .GoogleAdsBananer, .GoogleAdsInterstitial]
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOption.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = menuOption[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuOption[indexPath.row] {
        case .Login:
            AGGoogleLogin.shared.login(compilationHendler: { (googleUser) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            return
            
        case .GoogleAdsBananer:
            return
            
        case .GoogleAdsInterstitial:
            return
        }
    }
}
