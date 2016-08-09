//
//  UIKit+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import UIKit

extension UIImage {
    
    func thumbnailImage(size thumbnailSize: CGSize = .thumbnaiImagelSize) -> UIImage {
        UIGraphicsBeginImageContext(thumbnailSize)
        let widthScale = thumbnailSize.width / size.width, heightScale = thumbnailSize.height / size.height
        let scale = max(widthScale, heightScale)
        let center = CGRect(origin: .zero, size: thumbnailSize).center, scaledSize = size * scale
        drawInRect(CGRect(center: center, size: scaledSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension CGSize {
    
    static var thumbnaiImagelSize: CGSize {
        
        return CGSize(width: 256, height: 256)
    }
}

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint.zero, size: size)
        self.center = center
    }
    
    var center: CGPoint {
        get { return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMidY(self)) }
        set {
            origin.x = newValue.x - size.width/2
            origin.y = newValue.y - size.height/2
        }
    }
}

func *(size: CGSize, scale: CGFloat) -> CGSize {
    return CGSize(width: size.width * scale, height: size.height * scale)
}