//
//  UIView+Extension.swift
//  AGSocialLogin
//
//  Created by Wholly-iOS on 05/10/18.
//  Copyright © 2018 AshvinGudaliya. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func shake(duration: TimeInterval = 1, completion:(() -> Void)? = nil) {
        
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
}
