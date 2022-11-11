//
//  UIView+Ext.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/11.
//

import UIKit

extension UIView {
    
    func fadeTransition(_ duration: CFTimeInterval) {
        
        let animation = CATransition()
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        animation.type = CATransitionType.fade
        
        animation.duration = duration
        
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}
