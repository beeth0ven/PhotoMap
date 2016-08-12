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
    
    var userId: String?
    var creationTime: NSNumber?
    var imageS3Key: String?
    var thumbnailImageS3Key: String?
    var title: String?
    
}

extension Photo{
    
    var rx_user: Observable<UserInfo?> {
        return userId.flatMap { UserInfo.rx_get(userId: $0) } ?? Observable.just(nil)
    }
}


extension Photo: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-Photo"
    }
    
    static func hashKeyAttribute() -> String {
        return "userId"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationTime"
    }
}

extension Photo {
    
    @nonobjc static let cache = NSCache()
    
    
}

extension Photo {
    
    static func rx_insert(title title: String, image: UIImage) -> Observable<Photo> {
        return Observable.combineLatest(image.rx_saveToS3(), image.thumbnailImage().rx_saveToS3()) { (imageS3Key: $0, thumbnailImageS3Key: $1) }
            .map { keys in Photo(title: title, imageS3Key: keys.imageS3Key, thumbnailImageS3Key: keys.thumbnailImageS3Key) }
            .flatMap { $0.rx_save() }
    }
}

extension Photo {
    
    convenience init(title: String, imageS3Key: String, thumbnailImageS3Key: String) {
        self.init()
        self.userId = AWSIdentityManager.defaultIdentityManager().identityId!
        self.title = title
        self.imageS3Key = imageS3Key
        self.thumbnailImageS3Key = thumbnailImageS3Key
        self.creationTime = NSNumber(double: NSDate().timeIntervalSince1970)
    }
}
