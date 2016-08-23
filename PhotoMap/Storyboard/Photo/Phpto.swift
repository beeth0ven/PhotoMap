//
//  Phpto.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift

class Photo: AWSDynamoDBObjectModel {
    
    var userReference: String?
    var creationTime: NSNumber?
    var commentsNumber: NSNumber?
    var imageS3Key: String?
    var likesNumber: NSNumber?
    var thumbnailImageS3Key: String?
    var title: String?
    
    lazy var rx_user: Observable<UserInfo?> = UserInfo.rx_get(reference: self.userReference)
    lazy var recentComments: Observable<[Link]> = Link.rx_getComments(from: self, limit: 5)
}

extension Photo: AWSModelHasCreationDate {
    
    var likesCount: Int {
        get { return likesNumber?.integerValue ?? 0 }
        set { likesNumber = NSNumber(integer: newValue) }
    }
    
    var commentsCount: Int {
        get { return commentsNumber?.integerValue ?? 0 }
        set { commentsNumber = NSNumber(integer: newValue) }
    }
}

extension Photo: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-Photo"
    }
    
    static func hashKeyAttribute() -> String {
        return "userReference"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationTime"
    }
}

extension Photo {
    
    static func rx_insert(title title: String, image: UIImage) -> Observable<Photo> {
        return Observable.combineLatest(image.rx_saveToS3(), image.thumbnailImage().rx_saveToS3()) { (imageS3Key: $0, thumbnailImageS3Key: $1) }
            .flatMap { keys in Photo.rx_init(title: title, imageS3Key: keys.imageS3Key, thumbnailImageS3Key: keys.thumbnailImageS3Key) }
            .flatMap { $0.rx_save() }
    }
}

extension Photo {
    
    static func rx_init(title title: String, imageS3Key: String, thumbnailImageS3Key: String) -> Observable<Photo> {
        
        return UserInfo.currentUserInfo.map {
            let photo = Photo()
            photo.userReference = $0!.reference!
            photo.creationDate = NSDate()
            photo.commentsNumber = 0
            photo.imageS3Key = imageS3Key
            photo.thumbnailImageS3Key = thumbnailImageS3Key
            photo.likesNumber = 0
            photo.title = title
            return photo
        }
    }
}
