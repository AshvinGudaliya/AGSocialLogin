//
//  AGFacebookLogin.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/24/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit

class AGFacebookLogin: NSObject {
    
    //SDK Swift :- https://developers.facebook.com/docs/swift/
    typealias FacebookUserBlock = ((FacebookUser) -> ())
    
    static let shared = AGFacebookLogin()
    
    var isLogin: Bool {
        return FBSDKAccessToken.current() != nil
    }
    
    var user: FacebookUser?
    
    fileprivate let fbLoginManager = FBSDKLoginManager()
    
    fileprivate var rootViewController: UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    func login(compilationHendler: @escaping FacebookUserBlock) {
        
        if self.isLogin {
            self.fetchLoggedUserInfo(compilationHendler: compilationHendler)
        }
        else{
            fbLoginManager.logIn(withReadPermissions: ["public_profile", "user_friends", "email", "read_custom_friendlists"], from: rootViewController, handler: { (result, error) in
                if error == nil {
                    if result?.grantedPermissions != nil {
                        self.fetchLoggedUserInfo(compilationHendler: compilationHendler)
                        print("FBSDKLoginManager: Login")
                    }
                    else if result!.isCancelled {
                        print("FBSDKLoginManager: Cancelled")
                    }
                    else if result?.declinedPermissions != nil {
                        print("FBSDKLoginManager: declinedPermissions")
                    }
                }
                else{
                    print("FBSDKLoginManager: " + error!.localizedDescription)
                }
            })
        }
    }
    
    func logout() {
        if self.isLogin {
            fbLoginManager.logOut()
        }
    }
    
    func fetchLoggedUserInfo(compilationHendler: @escaping FacebookUserBlock) {
        let param: [AnyHashable: Any] = ["fields": "id, name, first_name, last_name, email, friends, cover, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: param).start(completionHandler: {(_, result, error) in
            if (error != nil) {
                print("FBSDKGraphRequest: " + error!.localizedDescription)
            }
            else{
                
                if let data = result as? NSDictionary {
                    self.user = FacebookUser(with: data)
                    compilationHendler(self.user!)
                }
            }
        })
    }
}

class FacebookUser: NSObject {
    var name: String
    var lastName: String
    var firstName: String
    var email: String
    var cover: Cover! = nil
    
    var idToken: String
    
    var profilePath: String = ""
    var profileimage: UIImage! = nil
    
    @discardableResult
    init(with dict: NSDictionary) {
        
        if let cover = dict.value(forKey: "cover") as? NSDictionary {
            self.cover = Cover(with: cover)
        }
        
        self.email = dict.value(forKey: "email") as? String ?? ""
        self.firstName = dict.value(forKey: "first_name") as? String ?? ""
        self.lastName = dict.value(forKey: "last_name") as? String ?? ""
        self.idToken = dict.value(forKey: "id") as? String ?? ""
        self.name = dict.value(forKey: "name") as? String ?? ""
        
        if let picture = dict.value(forKey: "picture") as? NSDictionary {
            if let data = picture.value(forKey: "data") as? NSDictionary {
                if let url = data.value(forKey: "url") as? String {
                    self.profilePath = url
                }
            }
        }
        
        super.init()
    }
    
    func downloadImage(with image: @escaping ((UIImage?, Error?) -> ())){
        if let url = URL(string: profilePath) {
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

class Cover: NSObject{
    var id: String
    var offset_x: NSNumber
    var offset_y: NSNumber
    var source: String
    
    init(with dict: NSDictionary) {
        self.id = dict.value(forKey: "id") as? String ?? ""
        self.offset_x = dict.value(forKey: "offset_x") as? NSNumber ?? 0
        self.offset_y = dict.value(forKey: "offset_y") as? NSNumber ?? 0
        self.source = dict.value(forKey: "source") as? String ?? ""
        
        super.init()
    }
}

// Info.plist
/*
 
 <key>CFBundleURLTypes</key>
 <array>
 <dict>
 <key>CFBundleURLSchemes</key>
 <array>
 <string>fb283599412024171</string>
 </array>
 </dict>
 </array>
 <key>FacebookAppID</key>
 <string>283599412024171</string>
 <key>FacebookDisplayName</key>
 <string>MyLoginDemo - Test1</string>
 
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>fbapi</string>
 <string>fb-messenger-api</string>
 <string>fbauth2</string>
 <string>fbshareextension</string>
 </array>
 
 
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
 
 FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
 
 return true
 }
 
 func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
 
 if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation){
 return true
 }
 
 return false
 }
 
 func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
 //        if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) {
 //            return true
 //        }
 
 if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[.sourceApplication] as! String, annotation: options[.annotation]) {
 return true
 }
 
 return false
 }
 
 */


