//
//  ViewController.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/23/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Social
import Accounts
import Branch

enum AGSocialTypes: String {
    case Google = "Google"
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Firebase = "Firebase"
    case LinkedIn = "LinkedIn"
    case InBuildFacebook = "In Build Facebook App"
    case InBuildTwitter = "In Build Twitter App"
    case Branch = "Branch"
    case Sinch = "Sinch Verification"
}

class ViewController: UITableViewController {

    var loginOption: [AGSocialTypes] = [.Google, .Facebook, .Twitter, .Firebase, .LinkedIn, .Branch, .Sinch]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Social Login"
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            loginOption.append(.InBuildFacebook)
        }
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            loginOption.append(.InBuildTwitter)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return loginOption.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AGSocialTypesCell") ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "AGSocialTypesCell")
        
        cell.textLabel?.text = loginOption[indexPath.row].rawValue
        cell.accessoryType = .none
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = UIColor.darkGray
        
        switch loginOption[indexPath.row] {
        case .Facebook:
            if AGFacebookLogin.shared.isLogin {
                cell.accessoryType = .checkmark
                AGFacebookLogin.shared.fetchLoggedUserInfo(compilationHendler: { (user) in
                    tableView.beginUpdates()
                    cell.detailTextLabel?.text = user.firstName + " " + user.lastName
                    tableView.endUpdates()
                })
            }
            break
            
        case .Twitter:
            if AGTwitterLogin.shared.isLogin {
                cell.accessoryType = .checkmark
                AGTwitterLogin.shared.fetchLoggedUserInfo(withCompletionHandler: { (user) in
                    tableView.beginUpdates()
                    cell.detailTextLabel?.text = user.userName
                    tableView.endUpdates()
                })
            }
            
        case .Firebase, .Google:
            cell.accessoryType = .disclosureIndicator
            
        default: break
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch loginOption[indexPath.row] {
        case .Google:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GoogleMobileAdsTableViewController") as! GoogleMobileAdsTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
            return
            
        case .Facebook:
            AGFacebookLogin.shared.login { (facebookUser) in
                print("Login Success")
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return
            
        case .Twitter:
            AGTwitterLogin.shared.login { (twitterUser) in
                print("Login Success")
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
        case .Firebase:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FirebaseTableViewController")
            self.navigationController?.pushViewController(vc!, animated: true)
            break
            
        case .LinkedIn:
            AGLinkedInLogin.shared.login(with: { (linkedInUser) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            break
        
        case .InBuildFacebook:
            let url: URL = URL(string: "http://www.google.es")!
            
            let fbController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbController?.setInitialText("")
            fbController?.add(url)
            
            let completionHandler = {(result:SLComposeViewControllerResult) -> () in
//                fbController?.dismiss(animated: true, completion:nil)
                switch(result){
                case SLComposeViewControllerResult.cancelled:
                    print("User canceled", terminator: "")
                case SLComposeViewControllerResult.done:
                    print("User posted", terminator: "")
                }
            }
            
            fbController?.completionHandler = completionHandler
            self.present(fbController!, animated: true, completion:nil)
            break
            
        case .InBuildTwitter:
            let image: UIImage = #imageLiteral(resourceName: "warning")
            
            let twitterController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterController?.setInitialText("")
            twitterController?.add(image)
            
            let completionHandler = {(result:SLComposeViewControllerResult) -> () in
//                twitterController?.dismiss(animated: true, completion: nil)
                switch(result){
                case SLComposeViewControllerResult.cancelled:
                    print("User canceled", terminator: "")
                case SLComposeViewControllerResult.done:
                    print("User tweeted", terminator: "")
                }
            }
            twitterController?.completionHandler = completionHandler
            self.present(twitterController!, animated: true, completion: nil)
            break
        
        case .Branch:
            
            let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: "Physeek Invite")
            branchUniversalObject.title = "Physeek Invite Link"
            branchUniversalObject.contentDescription = "My Content Description"
            branchUniversalObject.imageUrl = "https://example.com/mycontent-12345.png"
            
            let linkProperties: BranchLinkProperties = BranchLinkProperties()
            linkProperties.addControlParam("refferalUserName", withValue: "Static User")
            
            branchUniversalObject.getShortUrl(with: linkProperties, andCallback: { (url, error) in
                NSLog("done showing share sheet! :- \(url ?? "")")
                tableView.deselectRow(at: indexPath, animated: true)
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.detailTextLabel?.numberOfLines = 0
                    cell.detailTextLabel?.textColor = UIColor.darkGray
                    cell.detailTextLabel?.text = url
                }
            })
            
            break
            
        case .Sinch:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SinchLoginViewController")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}





