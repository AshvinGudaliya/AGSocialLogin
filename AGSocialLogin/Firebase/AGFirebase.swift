//
//  AGFirebase.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/26/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit

class AGFirebase: NSObject {

    static var shared = AGFirebase()
    
    var handle: AuthStateDidChangeListenerHandle!
    var user: User!
    
    override init() {
        super.init()
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let u = user{
                self.user = u
            }
        })
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    var isLogin: Bool {
        return Auth.auth().currentUser != nil
    }
    
    //sign up new users
    func createUser(with email: String, password: String, userDetailsBlock: @escaping ((User) -> ())) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                if let u = user {
                    userDetailsBlock(u.user)
                }
            }
        })
    }
    
    //Sign in existing users
    func signIn(with email: String, password: String, userDetailsBlock: @escaping ((User) -> ())){
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                if let u = user {
                    userDetailsBlock(u.user)
                }
            }
        })
    }
    
    func signIn(withPhoneAuth phoneNumber: String, userDetailsBlock: @escaping ((String) -> ())){

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                if let verificationID = verificationID {
                    userDetailsBlock(verificationID)
                }
            }
        }
    }
    
    func verifyPhone(withVerificationID verificationID: String, verificationCode: String, userDetailsBlock: @escaping ((User) -> ())){
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let err = error {
                print(err.localizedDescription)
            }
            else {
                if let auth = authResult {
                    userDetailsBlock(auth.user)
                }
            }
        }
    }
    
    func google(withHandler block: @escaping ((User, GoogleUser) -> ())) {
        AGGoogleLogin.shared.login(compilationHendler: { (googleUser) in

            guard let authentication = googleUser.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                }
                else {
                    if let u = user {
                        block(u, googleUser)
                    }
                }
            })
        }, isFirebase: true)
    }
    
    func facebook(withHandler block: @escaping ((User, FacebookUser) -> ())) {
        AGFacebookLogin.shared.login { (facebookUser) in
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                }
                else {
                    if let u = user {
                        block(u, facebookUser)
                    }
                }
            })
        }
    }
    
    func twitter(withHandler block: @escaping ((User, TwitterUser) -> ())) {
        AGTwitterLogin.shared.login { (twitterUser) in
            let credential = TwitterAuthProvider.credential(withToken: twitterUser.authToken, secret: twitterUser.authTokenSecret)
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                }
                else {
                    if let u = user {
                        block(u, twitterUser)
                    }
                }
            })
        }
    }
    
    func logOut(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError {
            print("Error signing out: %@", signOutError)
        }
    }
}



