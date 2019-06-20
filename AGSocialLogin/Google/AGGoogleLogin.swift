//
//  AGGoogleLogin.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/26/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class AGGoogleLogin: NSObject {
    
    //Google Login https://developers.google.com/identity/sign-in/ios/start?ver=swift
    //Config Files :- https://developers.google.com/mobile/add?platform=ios&cntapi=signin&cnturl=https:%2F%2Fdevelopers.google.com%2Fidentity%2Fsign-in%2Fios%2Fsign-in%3Fconfigured%3Dtrue&cntlbl=Continue%20Adding%20Sign-In

    typealias GoogleLoginActionBlock = ((GoogleUser) -> ())
    
    var googleLoginAction: GoogleLoginActionBlock?
    var user: GoogleUser?
    
    var isLogin: Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    fileprivate var rootViewController: UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static let shared = AGGoogleLogin()
    
    func login(compilationHendler: @escaping GoogleLoginActionBlock, isFirebase: Bool = false) {
        if !isLogin{
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().clientID = isFirebase ? FirebaseApp.app()?.options.clientID : "1050437933255-a1q2d95ejadp3sba4q6tl9qtka23mpm0.apps.googleusercontent.com"
            let signIn = GIDSignIn.sharedInstance()!
            signIn.shouldFetchBasicProfile = true
            signIn.scopes = ["profile"]
            signIn.uiDelegate = self
            
            GIDSignIn.sharedInstance().signIn()
            googleLoginAction = compilationHendler
        }
        else{
            self.signInSilently()
        }
    }
    
    func logout() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func disconnect() {
        GIDSignIn.sharedInstance().disconnect()
    }
    
    func fetchCurrentUserData() -> GoogleUser? {
        if self.isLogin {
            return GoogleUser(with: GIDSignIn.sharedInstance().currentUser)
        }
        return nil
    }
    
    func signInSilently() {
        GIDSignIn.sharedInstance().signInSilently()
    }
}

extension AGGoogleLogin: GIDSignInDelegate{
    
    func sign(_ signIn: GIDSignIn, didSignInFor user: GIDGoogleUser, withError error: Error?) {
        if error == nil {
            if let block = self.googleLoginAction {
                self.user = GoogleUser(with: user)
                block(self.user!)
            }
        }
        else {
            print("Google Login With Error :- \(error!.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn, didDisconnectWith user: GIDGoogleUser, withError error: Error?) {
        if error != nil {
            print("GIDSignIn: Disconnected user :- \(error!.localizedDescription)")
        }
        else{
            print("GIDSignIn: Google User Disconnected")
        }
    }
}

extension AGGoogleLogin:GIDSignInUIDelegate{
    
    func sign(_ signIn: GIDSignIn, present viewController: UIViewController) {
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn, dismiss viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

class GoogleUser: NSObject{
    
    var userId: String
    var idToken: String
    var givenName: String
    var fullName: String
    var familyName: String
    var email: String
    var phoneNumber: String
    var profileURL: URL?
    var authentication: GIDAuthentication?
    
    init(with user: GIDGoogleUser) {
        userId = user.userID
        
        idToken = user.authentication.idToken
        givenName = user.profile.givenName
        fullName = user.profile.name
        familyName = user.profile.familyName
        email = user.profile.email
        phoneNumber = ""
        
        // for firebase user
        authentication = user.authentication
        
        if user.profile.hasImage {
            let dimension = round(320 * UIScreen.main.scale)
            profileURL = user.profile.imageURL(withDimension: UInt(dimension))
        }

        super.init()
    }
    
    func downloadImage(with image: @escaping ((UIImage?, Error?) -> ())){
        if let url = profileURL {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else{
                    image(nil, error)
                    return
                }
                
                DispatchQueue.main.async {
                    image(UIImage(data: data), nil)
                }
                }.resume()
        }
    }
}

/*
 
 <key>CFBundleURLTypes</key>
	<array>
         <dict>
             <key>CFBundleTypeRole</key>
             <string>Editor</string>
             <key>CFBundleURLSchemes</key>
             <array>
             <string>com.googleusercontent.apps.1050437933255-a1q2d95ejadp3sba4q6tl9qtka23mpm0</string>
             </array>
         </dict>
	</array>
 
 func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
 
 if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,annotation: annotation){
 return true
 }
 
 return false
 }
 
 func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

 if GIDSignIn.sharedInstance().handle(url, sourceApplication: options[.sourceApplication] as! String,annotation: options[.annotation]){
 return true
 }
 
 return false
 }
 */
