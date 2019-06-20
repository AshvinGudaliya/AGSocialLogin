//
//  AGSinchVerification.swift
//  AGSocialLogin
//
//  Created by Wholly-iOS on 04/10/18.
//  Copyright © 2018 AshvinGudaliya. All rights reserved.
//

import UIKit
import SinchVerification

class AGSinchVerification: NSObject {

    static let shared = AGSinchVerification()
    
    var verification: Verification!;
    var applicationKey = "caf2f02d-7999-4231-99c7-932e3a3567b7";
    
    func calloutVerification(phoneNumber: String, complationBlock: @escaping ((InitiationResult) -> ())) {

        verification = CalloutVerification(applicationKey, phoneNumber: phoneNumber)
        
        verification.initiate { (isSuccess, error) in
            
            if let e = error {
                print(e.localizedDescription)
            }
            complationBlock(isSuccess)
        }
    }
    
    func smsVerification(phoneNumber: String, complationBlock: @escaping ((InitiationResult) -> ())) {

        verification = SMSVerification(applicationKey, phoneNumber: phoneNumber)
        
        verification.initiate { (isSuccess, error) in

            if let e = error {
                print(e.localizedDescription)
            }
            
            complationBlock(isSuccess)
        }
    }
    
    func verify(pinCode: String, complationBlock: @escaping ((Bool) -> ())) {

        verification.verify(pinCode, completion: { (isSuccess, error) in
            
            if let e = error {
                print(e.localizedDescription)
                complationBlock(false)
            }
            complationBlock(isSuccess)
        });
    }
}
