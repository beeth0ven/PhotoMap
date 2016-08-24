//
//  PhotoTableViewCell.swift
//  PhotoMap
//
//  Created by luojie on 16/8/24.
//
//

import UIKit


class PhotoTableViewCell: RxTableViewCell {
    
    var photo: Photo! {
        didSet { updateUI() }
    }
    
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var likesCountLabel: UILabel!
    @IBOutlet weak private var commentsCountLabel: UILabel!
    
    func updateUI() {
        
        photoImageView.s3_setImage(key: photo.imageS3Key)
        titleLabel.text = photo.title
        likesCountLabel.text = "likes: \(photo.likesCount)"
        commentsCountLabel.text = "comments: \(photo.commentsCount)"
        
    }
    
}

class UserInfoTableViewCell: RxTableViewCell {
    
    var userInfo: UserInfo!{
        didSet { updateUI() }
    }

    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    
    func updateUI() {
        usernameLabel.text = userInfo?.displayName
        userImageView.rx_setImage(url: userInfo?.imageURL)
    }
    
}

class CommentTableViewCell: RxTableViewCell {
    
    var comment: Link! {
        didSet { updateUI() }
    }

    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var contentLabel: UILabel!
    
    func updateUI() {
        
        contentLabel.text = comment.content
        dateLabel.text = comment.creationDate.flatMap(NSDateFormatter.string)
        
        comment.rx_fromUser
            .subscribeNext { [unowned self] userInfo in
                self.usernameLabel.text = userInfo?.displayName
                self.userImageView.rx_setImage(url: userInfo?.imageURL)
            }
            .addDisposableTo(prepareForReuseDisposeBag)
    }

}