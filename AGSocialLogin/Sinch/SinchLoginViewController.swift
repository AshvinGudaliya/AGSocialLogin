//
//  SinchLoginViewController.swift
//  AGSocialLogin
//
//  Created by Wholly-iOS on 05/10/18.
//  Copyright © 2018 AshvinGudaliya. All rights reserved.
//

import UIKit
import CTKFlagPhoneNumber
import TransitionButton

class SinchLoginViewController: UIViewController {

    @IBOutlet weak var txtPhoneNumber: CTKFlagPhoneNumberTextField!
    @IBOutlet weak var btnSendOtp: TransitionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtPhoneNumber.setFlag(for: ((Locale.current as NSLocale).object(forKey: .countryCode) as? String) ?? "cn")
        txtPhoneNumber.flagSize = CGSize(width: 44, height: 44)
        txtPhoneNumber.backgroundColor = UIColor.clear
        txtPhoneNumber.textColor = UIColor.white
        txtPhoneNumber.borderStyle = .none
        
        txtPhoneNumber.backgroundColor = .black
        txtPhoneNumber.parentViewController = self
        txtPhoneNumber.layer.cornerRadius = 5
        txtPhoneNumber.layer.masksToBounds = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func veryfyPhoneNumber() -> Bool{
        if let phoneNumberStr = self.txtPhoneNumber.getRawPhoneNumber() {
            if let phoneCode = self.txtPhoneNumber.getCountryPhoneCode() {
                UserModel.shared.CountryCode = phoneCode
            }
            
            UserModel.shared.fullPhoneNumber = phoneNumberStr
            
            UserModel.shared.Phone = phoneNumberStr.replacingOccurrences(of: "+\(UserModel.shared.CountryCode)", with: "")
            
            UserModel.shared.Country = self.txtPhoneNumber.getCountryCode() ?? "cn"

            return true
        }
        else{
            return false
        }
    }
    
    @IBAction func buttonAction(_ button: TransitionButton) {
        if veryfyPhoneNumber() {
            button.startAnimation()
            
            AGSinchVerification.shared.smsVerification(phoneNumber: "+\(UserModel.shared.fullPhoneNumber)") { (result) in
                
                button.stopAnimation(animationStyle: .normal, completion: {
                    if result.success {
                        
                    }
                    else{
                        button.shake()
                    }
                })
            }
        }
        else{
            button.shake()
        }
    }
}


class UserModel {
    static let shared = UserModel()
    
    var CountryCode: String = ""
    var Phone: String = ""
    var fullPhoneNumber: String = ""
    var Country: String = ""
}
