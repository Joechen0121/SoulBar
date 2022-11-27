//
//  UIAlert+Ext.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/25.
//

import UIKit

extension UIAlertController {
    
    func addImage(image: UIImage) {
        
        let maxSize = CGSize(width: 245, height: 300)
        
        let imageSize = image.size

        var ratio: CGFloat
        
        if imageSize.width > imageSize.height {
            
            ratio = maxSize.width / imageSize.width
        }
        else {
            
            ratio = maxSize.height / imageSize.height
        }
        
        let scaleSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        
        var resizedImage = image.imageWithSize(scaleSize)
    
        if imageSize.height > imageSize.width {
            
            let left = (maxSize.width - resizedImage.size.width ) / 2
            
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
        }
        
        let imageAction = UIAlertAction(title: "", style: .default)
        
        imageAction.isEnabled = false
        
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        self.addAction(imageAction)
        
    }
    
}
