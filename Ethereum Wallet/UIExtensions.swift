//
//  UIExtensions.swift
//  Ethereum Wallet
//
//  Created by harsh vishwakrama on 7/16/17.
//  Copyright © 2017 Darwin Labs. All rights reserved.
//

import Foundation
import UIKit

extension CALayer{
    
    var borderUIColor: UIColor?{
        get{
            return UIColor(cgColor: borderColor ?? UIColor.clear.cgColor)
        }
        set{
            borderColor = newValue?.cgColor
        }
    }
}

extension UIViewController{
    @discardableResult
    func alert(_ title: String, message: String, cancellable: Bool = false , ok: String = "Ok", action: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // add primary action
        alert.addAction(UIAlertAction(title: ok, style: .default, handler: action))
        
        // add cancel action
        if cancellable{
            alert.addAction(UIAlertAction(title: StringConstants.Cancel, style: .cancel, handler: nil))
        }
        
        let attributedString = NSAttributedString(string: title, attributes: [
            NSForegroundColorAttributeName : UIColor.red
            ])
        
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        present(alert, animated: true, completion: nil)
        
        return alert
    }
}


extension UIView{
    func addMaximized(view childView: UIView, at position: Int? = nil){
        
        if let position = position{
            insertSubview(childView, at: position)
        }else{
            addSubview(childView)
        }
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutAttributes: [NSLayoutAttribute] = [.top, .leading, .bottom, .trailing]
        
        layoutAttributes.forEach { attribute in
            addConstraint(NSLayoutConstraint(item: childView,
                                             attribute: attribute,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: attribute,
                                             multiplier: 1,
                                             constant: 0.0))
        }
    }
    
    func addCentered(view childView: UIView, at position: Int? = nil){
        
        if let position = position{
            insertSubview(childView, at: position)
        }else{
            addSubview(childView)
        }
        
        
        childView.bounds.origin = CGPoint(x: childView.bounds.midX, y: childView.bounds.midY)
        
        childView.translatesAutoresizingMaskIntoConstraints = false
        
        childView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        childView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
}

extension UIImage{
    
    func tint(color: UIColor) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        context!.setBlendMode(.multiply)
        
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.translateBy(x: 0.0, y: -self.size.height)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.clip(to: rect, mask: self.cgImage!)
        
        color.setFill()
        context!.fill(rect)
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}


extension UIImageView{
    
    func setQRCodefrom(string: String){
        let stringData = string.data(using: .utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue(stringData, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let qrImage = filter.outputImage{
                
                let scaleX = self.frame.size.width / qrImage.extent.size.width
                let scaleY = self.frame.size.height / qrImage.extent.size.height
                
                /// uiimage from ciimage
                let finalImage = UIImage(ciImage: qrImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY)))
                
                self.image = finalImage
            }
        }
    }
}
