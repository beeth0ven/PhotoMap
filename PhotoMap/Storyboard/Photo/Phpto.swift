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
            
            return Link.rx_get(indexIdentifier: .item) {
                $0.when(key: "itemReference", isEqualTo: self.reference! as AnyObject)
                    .filter(key: "fromUserReference", isEqualTo: userInfo!.reference! as AnyObject)
                    .filter(key: "kindRawValue", isEqualTo: Link.Kind.likePhoto.rawValue as AnyObject)
                }
                .map { $0.first }
                .shareReplay(1)
        }
        
    }()
}

extension Photo: AWSModelHasCreationDate {
    
    var likesCount: Int {
        get { return likesNumber?.intValue ?? 0 }
        set { likesNumber = NSNumber(value: newValue as Int) }
    }
    
    var commentsCount: Int {
        get { return commentsNumber?.intValue ?? 0 }
        set { commentsNumber = NSNumber(value: newValue as Int) }
    }
    
    var rx_likesCount: Driver<Int> { return rx_count(key: "likesCount") }
    
    var rx_commentsCount: Driver<Int> { return rx_count(key: "commentsCount") }
    
    func rx_setLike(_ liked: Bool) -> Observable<Link> {
        
        if liked {
            return Link.rx_insertLikeLink(to: self)
                .do(onNext: {  _ in self.likesCount += 1 })
        } else {
            return rx_likePhotoLink
                .filter { $0 != nil }
                .flatMap { $0!.rx_delete() }
                .do(onNext: {  _ in self.likesCount += -1 })
        }
    }
    
    func rx_insertComment(content: String?) -> Observable<Link> {
        return Link.rx_insertComment(to: self, content: content)
            .do(onNext: { _ in self.commentsCount += 1 })
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
    
    static func rx_insert(title: String, image: UIImage) -> Observable<Photo> {
        return Observable.combineLatest(image.rx_saveToS3(), image.thumbnailImage().rx_saveToS3()) { (imageS3Key: $0, thumbnailImageS3Key: $1) }
            .flatMap { keys in Photo.rx_init(title: title, imageS3Key: keys.imageS3Key, thumbnailImageS3Key: keys.thumbnailImageS3Key) }
            .flatMap { $0.rx_save() }
    }
}

extension Photo {
    
    static func rx_init(title: String, imageS3Key: String, thumbnailImageS3Key: String) -> Observable<Photo> {
        
        return UserInfo.currentUserInfo.map {
            let photo = Photo()!
            photo.userReference = $0!.reference!
            photo.creationDate = Date()
            photo.commentsNumber = 0
            photo.imageS3Key = imageS3Key
            photo.thumbnailImageS3Key = thumbnailImageS3Key
            photo.likesNumber = 0
            photo.title = title
            return photo
        }
    }
}
