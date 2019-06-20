//
//  FirebaseTableViewController.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/27/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseInvites

enum AGFirebaseType: String{
    case newCreate = "Email/Password New Create"
    case register = "Email/Password Register"
    case phone = "Phone"
    case google = "Google"
    case facebook = "Facebook"
    case twitter = "Twitter"
    case github = "GitHub"
    case anonymous = "Anonymous"
    case logout = "Logout"
    case invites = "Invites"
}

class FirebaseTableViewController: UITableViewController {
    
    var loginOption: [AGFirebaseType] = [.newCreate, .register, .phone, .google, .facebook, .twitter, .github, .anonymous, .invites]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Social Login Using Firebase"
        
        if AGFirebase.shared.isLogin {
           loginOption.append(.logout)
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
        let cell = UITableViewCell()
        cell.textLabel?.text = loginOption[indexPath.row].rawValue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch loginOption[indexPath.row] {
        case  .newCreate:
            AGFirebase.shared.createUser(with: "ashvin", password: "tems", userDetailsBlock: { (firUser) in
                print("Login success \(firUser.providerID)")
                tableView.deselectRow(at: indexPath, animated: true)
            })
            break
            
        case .register:
            AGFirebase.shared.signIn(with: "ashvin", password: "tems", userDetailsBlock: { (firUser) in
                print("Login success \(firUser.providerID)")
                tableView.deselectRow(at: indexPath, animated: true)
            })
            break
            
        case .phone:
            AGFirebase.shared.signIn(withPhoneAuth: "+919601518691") { (verificationID) in
                
            }
            break
            
        case .google:
            AGFirebase.shared.google(withHandler: { (firUser, googleuser) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            return
            
        case .facebook:
            AGFirebase.shared.facebook(withHandler: { (firUser, facebookUser) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            return
            
        case .twitter:
            AGFirebase.shared.twitter(withHandler: { (firuser, twitterUser) in
                tableView.deselectRow(at: indexPath, animated: true)
            })
            break
            
        case .github:
            break
        
        case .anonymous:
            break
            
        case .invites:
            if let invite = Invites.inviteDialog() {
                invite.setInviteDelegate(self)
                
                // NOTE: You must have the App Store ID set in your developer console project
                // in order for invitations to successfully be sent.
                // A message hint for the dialog. Note this manifests differently depending on the
                // received invitation type. For example, in an email invite this appears as the subject.
                invite.setMessage("Try this out!\n -\(GIDSignIn.sharedInstance().currentUser.profile.name)")
                // Title for the dialog, this is what the user sees before sending the invites.
                invite.setTitle("Invites Example")
                invite.setDeepLink("app_url")
                invite.setCallToActionText("Install!")
                invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
                invite.open()
            }
            
        case .logout:
            AGFirebase.shared.logOut()
            loginOption.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension FirebaseTableViewController: InviteDelegate {
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            print("\(invitationIds.count) invites sent")
        }
    }
}
