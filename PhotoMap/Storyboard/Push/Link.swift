//
//  Link.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift

class Link: AWSDynamoDBObjectModel {
    
    var fromUserReference: String?
    var creationTime: NSNumber?
    var toUserReference: String?
    var itemReference: String?
    var kindRawValue: NSNumber?
    var content: String?
}

extension Link: AWSModelHasCreationDate {
    
    var rx_fromUser: Observable<UserInfo?> {
        return fromUserReference.flatMap { UserInfo.rx_get(reference: $0) } ?? Observable.just(nil)
    }
    
    var rx_toUser: Observable<UserInfo?> {
        return toUserReference.flatMap { UserInfo.rx_get(reference: $0) } ?? Observable.just(nil)
    }
    
    var rx_photo: Observable<Photo?> {
        return itemReference.flatMap { Photo.rx_get(reference: $0) } ?? Observable.just(nil)
    }
    
    var kind: Kind! {
        get { return Kind(rawValue: kindRawValue!.integerValue) }
        set { kindRawValue = NSNumber(integer: newValue.rawValue) }
    }
    
    enum Kind: Int {
        case followUser
        case likePhoto
        case commentPhoto
    }
}

extension Link: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-Link"
    }
    
    static func hashKeyAttribute() -> String {
        return "fromUserReference"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationTime"
    }
}

extension Link: AWSHasTableIndex {
    
    enum IndexIdentifier: String {
        case toUser = "toUserReference-creationTime"
        case item = "itemReference-creationTime"
    }
    
    static func rx_getComments(from photo: Photo, limit: Int? = nil) -> Observable<[Link]> {
        
        let predicate = AWSDynamoDBQueryExpression()
            .when(key: "itemReference", isEqualTo: photo.reference!)
            .filter(key: "kindRawValue", isEqualTo: Kind.commentPhoto.rawValue)
        
        predicate.limit = limit.flatMap(NSNumber.init(integer:))
        
        return rx_get(indexIdentifier: .item, predicate: predicate)
    }
    
}

extension Link {
    
    static func rx_insertComment(to photo: Photo, content: String?) -> Observable<Link> {
        return rx_init()
            .doOnNext {
                $0.toUserReference = photo.userReference
                $0.itemReference = photo.reference
                $0.kind = .commentPhoto
                $0.content = content
            }
            .flatMap { $0.rx_save() }
    }
}

extension Link {
    
    static func rx_init() -> Observable<Link> {
        return UserInfo.currentUserInfo.map {
            let link = Link()
            link.creationDate = NSDate()
            link.fromUserReference = $0!.reference!
            return link
        }
    }
    
}

