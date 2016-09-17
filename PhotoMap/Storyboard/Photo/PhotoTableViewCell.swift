//
//  PhotoTableViewCell.swift
//  PhotoMap
//
//  Created by luojie on 16/8/24.
//
//

import UIKit
import RxSwift
import RxCocoa
import AWSDynamoDB

class PhotoTableViewCell: RxTableViewCell {
    
    var photo: Photo! {
        didSet { updateUI() }
    }
    
    @IBOutlet fileprivate weak var photoImageView: UIImageView!
    @IBOutlet weak fileprivate var titleLabel: UILabel!
    @IBOutlet weak fileprivate var likesCountLabel: UILabel!
    @IBOutlet weak fileprivate var commentsCountLabel: UILabel!
    @IBOutlet weak fileprivate var likeButton: UIButton!
    
    func updateUI() {
        
        photoImageView.s3_setImage(key: photo.imageS3Key)
        titleLabel.text = photo.title
        
        photo.rx_likesCount.drive(onNext: { [unowned self] count in
            self.likesCountLabel.text = "likes: \(count)"
            })
            .addDisposableTo(prepareForReuseDisposeBag)
        
        photo.rx_commentsCount.drive(onNext: { [unowned self] count in
            self.commentsCountLabel.text = "comments: \(count)"
            })            .addDisposableTo(prepareForReuseDisposeBag)
        
        photo.rx_likePhotoLink
            .do(onError: {  error in print(error) })
            .subscribe(onNext: { [unowned self] link in
                self.likeButton.isEnabled = true
                self.likeButton.isSelected = (link != nil)
            })
            .addDisposableTo(prepareForReuseDisposeBag)
    }
}

class UserInfoTableViewCell: RxTableViewCell {
    
    var userInfo: UserInfo!{
        didSet { updateUI() }
    }

    @IBOutlet weak fileprivate var userImageView: UIImageView!
    @IBOutlet weak fileprivate var usernameLabel: UILabel!
    
    func updateUI() {
        usernameLabel.text = userInfo?.displayName
        userImageView.rx_setImage(url: userInfo?.imageURL)
    }
    
}

class CommentTableViewCell: RxTableViewCell {
    
    var comment: Link! {
        didSet { updateUI() }
    }

    @IBOutlet weak fileprivate var userImageView: UIImageView!
    @IBOutlet weak fileprivate var usernameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    @IBOutlet weak fileprivate var contentLabel: UILabel!
    
    func updateUI() {
        
        contentLabel.text = comment.content
        dateLabel.text = comment.creationDate.flatMap(DateFormatter.string)
        
        comment.rx_fromUser
            .subscribe(onNext: { [unowned self] userInfo in
                self.usernameLabel.text = userInfo?.displayName
                self.userImageView.rx_setImage(url: userInfo?.imageURL)
            })
            .addDisposableTo(prepareForReuseDisposeBag)
    }

}
