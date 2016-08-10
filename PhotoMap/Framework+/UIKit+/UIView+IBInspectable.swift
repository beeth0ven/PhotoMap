//
//  UIView+IBInspectable.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
}

