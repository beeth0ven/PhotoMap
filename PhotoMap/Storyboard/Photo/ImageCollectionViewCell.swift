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

class ImageCollectionViewCell: RxCollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subtitleLabel: UILabel!
    
    func update(with model: Photo) {
        
        imageView.s3_setImage(key: model.thumbnailImageS3Key)
        titleLabel.text = model.title
        model.rx_user
            .subscribeNext { [unowned self] userInfo in
                self.subtitleLabel.text = userInfo?.displayName
            }
            .addDisposableTo(prepareForReuseDisposeBag)
    }
}