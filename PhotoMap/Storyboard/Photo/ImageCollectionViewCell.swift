//
//  ImageCollectionViewCell.swift
//  PhotoMap
//
//  Created by luojie on 16/7/28.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubHelper

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    func update(with model: ImageCollectionViewCellModeled) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        imageView.s3_setImage(key: model.s3ImageKey)
    }
}


protocol ImageCollectionViewCellModeled {
    var title: String? { get }
    var subtitle: String? { get }
    var s3ImageKey: String? { get }
}

extension ImageCollectionViewCellModeled {
    var subtitle: String? {
        return nil
    }
}

extension Photo: ImageCollectionViewCellModeled {
    
    var subtitle: String? {
        return creationTime?.toDateString
    }
    
    var s3ImageKey: String? {
        return thumbnailImageS3Key
    }
}

extension NSNumber {
    var toDateString: String? {
        let date = NSDate(timeIntervalSince1970: doubleValue)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
}