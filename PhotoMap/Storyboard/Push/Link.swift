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
    
    lazy var rx_fromUser: Observable<UserInfo?> = UserInfo.rx_get(reference: self.fromUserReference)
    lazy var rx_toUser: Observable<UserInfo?> = UserInfo.rx_get(reference: self.toUserReference)
    lazy var rx_photo: Observable<Photo?> = Photo.rx_get(reference: self.itemReference)
}

extension Link: AWSModelHasCreationDate {
    
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
            let result = Link()
            result.creationDate = NSDate()
            result.fromUserReference = $0!.reference!
            return result
        }
    }
    
}

