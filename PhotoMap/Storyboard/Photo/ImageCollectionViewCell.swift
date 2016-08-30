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
    @IBOutlet weak private var likesCountLabel: UILabel!
    @IBOutlet weak private var commentsCountLabel: UILabel!
    
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    
    var photo: Photo! {
        didSet { updateUI() }
    }
    
    func updateUI() {
        
        imageView.s3_setImage(key: photo.thumbnailImageS3Key)
        titleLabel.text = photo.title
        commentsCountLabel.text = "comments: \(photo.commentsCount)"
        
        photo.rx_likesCount.driveNext { [unowned self] count in
            self.likesCountLabel.text = "likes: \(count)"
            }
            .addDisposableTo(prepareForReuseDisposeBag)
        
        photo.rx_commentsCount.driveNext { [unowned self] count in
            self.commentsCountLabel.text = "comments: \(count)"
            }
            .addDisposableTo(prepareForReuseDisposeBag)
        
        photo.rx_user.subscribeNext { [unowned self] userInfo in
            self.usernameLabel.text = userInfo?.displayName
            self.userImageView.rx_setImage(url: userInfo?.imageURL)
            }
            .addDisposableTo(prepareForReuseDisposeBag)
        
    }
    
}
