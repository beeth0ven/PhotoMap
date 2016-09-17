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
        draw(in: CGRect(center: center, size: scaledSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

