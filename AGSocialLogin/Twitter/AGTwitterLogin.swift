//
//  AGTwitterLogin.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/26/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import TwitterKit

class AGTwitterLogin: NSObject {

    static func configure(){
        TWTRTwitter.sharedInstance().start(withConsumerKey: "lvciDUgKSUHiVyHVWQqPsaAoS", consumerSecret: "QyRAivm6aAkIgQWhI6x4qgSCDgS5wB4GJsygQcOTU1XBvLmgPo")
    }
    
    static var shared = AGTwitterLogin()
    fileprivate var rootViewController: UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    var user: TwitterUser?
    
    typealias TwitterLoginActionBlock = ((TwitterUser) -> ())
    var currentSession: TWTRSession? = TWTRTwitter.sharedInstance().sessionStore.session() as? TWTRSession
    
    func button(withCompletionHandler: @escaping TwitterLoginActionBlock) -> TWTRLogInButton{
        return TWTRLogInButton(logInCompletion: { session, error in
            if let currentUser = session {
                self.currentSession = currentUser
                self.fetchLoggedUserInfo(withCompletionHandler: withCompletionHandler)
            } else {
                print("error: \(error!.localizedDescription)");
            }
        })
    }
    
    func login(withCompletionHandler: @escaping TwitterLoginActionBlock) {

        if isLogin {
            self.fetchLoggedUserInfo(withCompletionHandler: withCompletionHandler)
        }
        else{
            TWTRTwitter.sharedInstance().logIn(with: rootViewController) { (session, error) in
                if let currentUser = session {
                    self.currentSession = currentUser
                    self.fetchLoggedUserInfo(withCompletionHandler: withCompletionHandler)
                } else {
                    print("error: \(error!.localizedDescription)");
                }
            }
        }
    }
    
    func fetchLoggedUserInfo(withCompletionHandler: @escaping TwitterLoginActionBlock){

        guard let session = currentSession else {
            return
        }
        
        TWTRAPIClient.withCurrentUser().loadUser(withID: session.userID) { (user, error) in
            if let user = user {
                self.user = TwitterUser(with: user, session: session)
                withCompletionHandler(self.user!)
            }
            else{
                print(error?.localizedDescription ?? "Error in login")
            }
        }
        
        TWTRAPIClient.withCurrentUser().requestEmail { email, error in

            if (email != nil) {
                print("signed in as \(session.userName)");
            } else {
                print("error: \(error!.localizedDescription)");
            }
        }
    }
    
    var isLogin: Bool {
        return TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers()
    }
    
    func logout(){
        
        if let userID = currentSession?.userID {
            TWTRTwitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
    }
}

class TwitterUser: NSObject{
    
    var authToken: String
    var authTokenSecret: String
    var userName: String
    
    var userID: String
    var name: String
    var screenName: String
    var isVerified: Bool
    var isProtected: Bool
    var profileImageURL: String
    var profileImageMiniURL: String
    var profileImageLargeURL: String
    var formattedScreenName: String
    var profileURL: URL?
    
    init(with user: TWTRUser, session: TWTRSession) {
        userID = user.userID
        name = user.name
        screenName = user.screenName
        isVerified = user.isVerified
        isProtected = user.isProtected
        profileImageURL = user.profileImageURL
        profileImageMiniURL = user.profileImageMiniURL
        profileImageLargeURL = user.profileImageLargeURL
        formattedScreenName = user.formattedScreenName
        profileURL = user.profileURL
        
        authToken = session.authToken
        userName = session.userName
        authTokenSecret = session.authTokenSecret
        
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
 <key>CFBundleURLSchemes</key>
 <array>
 <string>twitterkit-<consumerKey></string>
 </array>
 </dict>
 </array>
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>twitter</string>
 <string>twitterauth</string>
 </array>
 
 func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
 
 if Twitter.sharedInstance().application(app, open: url, options: options) {
 return true
 }
 
 return false
 }
 */

