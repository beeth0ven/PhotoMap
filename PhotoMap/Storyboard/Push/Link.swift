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
    
    var fromUserId: String?
    var creationTime: NSNumber?
    var toUserId: String?
    var toItemId: NSNumber?
    var kindRawValue: NSNumber?
    var content: String?
}

extension Link {
    
    var rx_fromUser: Observable<UserInfo?> {
        return fromUserId.flatMap { UserInfo.rx_get(hashValue: $0) } ?? Observable.just(nil)
    }
    
    var rx_toUser: Observable<UserInfo?> {
        return toUserId.flatMap { UserInfo.rx_get(hashValue: $0) } ?? Observable.just(nil)
    }
    
    var rx_photo: Observable<Photo?> {
        return toItemId.flatMap { Photo.rx_get(hashValue: $0) } ?? Observable.just(nil)
    }
    
    var kind: Kind! {
        get { return Kind(rawValue: kindRawValue!.integerValue) }
        set { kindRawValue = NSNumber(integer: newValue.rawValue) }
    }
    
    enum Kind: Int {
        case FollowUser
        case LikePhoto
        case CommentPhoto
    }
}

extension Link: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-Link"
    }
    
    static func hashKeyAttribute() -> String {
        return "fromUserId"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationTime"
    }
    
}
