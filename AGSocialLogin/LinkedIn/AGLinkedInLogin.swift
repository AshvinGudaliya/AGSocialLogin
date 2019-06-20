//
//  AGLinkedInLogin.swift
//  AGSocialLogin
//
//  Created by Ashvin Gudaliya on 11/27/17.
//  Copyright © 2017 AshvinGudaliya. All rights reserved.
//

import UIKit
import LinkedinSwift

class AGLinkedInLogin: NSObject {
    
    static let shared = AGLinkedInLogin()
    typealias LinkedInUserBlock = ((LinkedInUser) -> ())
    
    var linkedInUserBlock: LinkedInUserBlock? = nil
    
    static let redirectUrl = "https://com.appcoda.linkedin.oauth/oauth"
    
    let configuration: LinkedinSwiftConfiguration = LinkedinSwiftConfiguration(clientId: "81if01kg70zuwh", clientSecret: "g04YdJFAugaibrXE", state: "linkedin\(Int(NSDate().timeIntervalSince1970))", permissions: ["r_basicprofile", "r_emailaddress"], redirectUrl: AGLinkedInLogin.redirectUrl)
    
    var linkedinHelper: LinkedinSwiftHelper! = nil
    
    override init() {
        super.init()
        linkedinHelper = LinkedinSwiftHelper(configuration: configuration)
    }
    
    func login(with completion: @escaping ((LinkedInUser) -> ())){
        linkedinHelper.authorizeSuccess({ (lsToken) -> Void in
            self.getRequest()
        }, error: { (error) -> Void in
            print("error: \(error.localizedDescription)");
        }, cancel: { () -> Void in
            NSLog("User Cancel")
        })
        
        self.linkedInUserBlock = completion
    }
    
    var isLogin: Bool {
        return LISDKSessionManager.hasValidSession()
    }
    
    func logOut(){
        if self.isLogin {
            LISDKSessionManager.clearSession()
        }
    }
    
    func getRequest(){
        linkedinHelper.requestURL("https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address,picture-urls::(original))?format=json", requestType: LinkedinSwiftRequestGet, success: { (response) -> Void in
            debugPrint(response.jsonObject)
            if let block = self.linkedInUserBlock {
                block(LinkedInUser(with: response.jsonObject as! [String : AnyObject]))
            }
            
        }) { (error) -> Void in
            print("error: \(error.localizedDescription)");
        }
    }
    
}

class LinkedInUser: NSObject {
    var firstName: String = ""
    var id: String = ""
    var lastName: String = ""
    var url: String = ""
    var emailAddress: String = ""
    
    override init() {
        super.init()
    }
    
    required init(with response: [String: AnyObject]) {
        super.init()
        self.firstName = response["firstName"] as? String ?? ""
        self.id = response["id"] as? String ?? ""
        self.lastName = response["lastName"] as? String ?? ""
        self.emailAddress = response["emailAddress"] as? String ?? ""
        
        if let userProfileUrl = response["pictureUrls"] as? [String: AnyObject], let image = (userProfileUrl["values"] as? [String])?.first {
            self.url = image as String
        }
    }
}

