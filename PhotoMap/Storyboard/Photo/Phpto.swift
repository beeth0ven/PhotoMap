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
import RxCocoa

class Photo: AWSDynamoDBObjectModel {
    
    var userReference: String?
    var creationTime: NSNumber?
    var commentsNumber: NSNumber?
    var imageS3Key: String?
    var likesNumber: NSNumber?
    var thumbnailImageS3Key: String?
    var title: String?
    
    lazy var rx_user: Observable<UserInfo?> = UserInfo.rx_get(reference: self.userReference)
    lazy var recentComments: Observable<[Link]> = Link.rx_getComments(from: self, limit: nil)
    
     lazy var rx_likePhotoLink: Observable<Link?> = {
        
        return UserInfo.currentUserInfo.flatMap {  userInfo -> Observable<Link?> in
            
            let predicate = AWSDynamoDBQueryExpression()
                .when(key: "itemReference", isEqualTo: self.reference!)
                .filter(key: "fromUserReference", isEqualTo: userInfo!.reference!)
                .filter(key: "kindRawValue", isEqualTo: Link.Kind.likePhoto.rawValue)
            
            return Link.rx_get(indexIdentifier: .item, predicate: predicate)
                .map { $0.first }
                .shareReplay(1)
        }
        
    }()
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
    
    var rx_likesCount: Driver<Int> {
        return rx_observe(Int.self, "likesCount")
            .map { $0! }
            .asDriver(onErrorDriveWith: Driver.empty())
    }
    
    var rx_commentsCount: Driver<Int> {
        return rx_observe(Int.self, "commentsCount")
            .map { $0! }
            .asDriver(onErrorDriveWith: Driver.empty())
    }
    
    func rx_setLike(liked: Bool) -> Observable<Link> {
        
        if liked {
            return Link.rx_insertLikeLink(to: self)
                .doOnNext {  _ in self.likesCount += 1 }
        } else {
            return rx_likePhotoLink
                .filter { $0 != nil }
                .flatMap { $0!.rx_delete() }
                .doOnNext {  _ in self.likesCount += -1 }
        }
    }
    
    func rx_insertComment(content content: String?) -> Observable<Link> {
        return Link.rx_insertComment(to: self, content: content)
            .doOnNext { _ in self.commentsCount += 1 }
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
    
    static func ignoreAttributes() -> [String] {
        return ["likesCount", "commentsCount"]
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
