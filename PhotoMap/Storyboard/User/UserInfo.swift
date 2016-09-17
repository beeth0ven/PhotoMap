//
//  UserInfo.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class UserInfo: AWSDynamoDBObjectModel {
    
    var userId: String?
    var creationTime: NSNumber?
    var displayName: String?
    var followersNumber: NSNumber?
    var followingNumber: NSNumber?
    var imagePath: String?
    var likedNumber: NSNumber?
    var postedNumber: NSNumber?
    var snsTopicArn: String?
    
    lazy var rx_postedPhotos: Observable<[Photo]> = {
        guard let reference = self.reference else { return Observable.empty() }
        
        return Photo.rx_get() {
            $0.when(key: "userReference", isEqualTo: reference as AnyObject)
            }
            .shareReplay(1)
    }()
    
    lazy var rx_likedPhotos: Observable<[Photo]> = {
        
        guard let reference = self.reference else { return Observable.empty() }
        
        return Link.rx_get(predicate: {
            $0.when(key: "fromUserReference", isEqualTo: reference as AnyObject)
                .filter(key: "kindRawValue", isEqualTo: Link.Kind.likePhoto.rawValue as AnyObject)
            })
            .map { $0.flatMap { $0.itemReference } }
            .flatMap { Photo.rx_get(references: $0) }
            .shareReplay(1)
    }()
    
    lazy var rx_followerUsers: Observable<[UserInfo]> = {
        
        guard let reference = self.reference else { return Observable.empty() }
        print("rx_followerUsers", reference)
        
        return Link.rx_get(indexIdentifier: .toUser) {
            $0.when(key: "toUserReference", isEqualTo: reference as AnyObject)
                .filter(key: "kindRawValue", isEqualTo: Link.Kind.followUser.rawValue as AnyObject)
            }
            .map { $0.flatMap { $0.fromUserReference } }
            .flatMap { UserInfo.rx_get(references: $0) }
            .shareReplay(1)
    }()
    
    lazy var rx_followingUsers: Observable<[UserInfo]> = {
        
        guard let reference = self.reference else { return Observable.empty() }
        print("rx_followingUsers", reference)
        
        return Link.rx_get(predicate: {
            $0.when(key: "fromUserReference", isEqualTo: reference as AnyObject)
                .filter(key: "kindRawValue", isEqualTo: Link.Kind.followUser.rawValue as AnyObject)
            })
            .map { $0.flatMap { $0.toUserReference } }
            .flatMap { UserInfo.rx_get(references: $0) }
            .shareReplay(1)
    }()
    
    lazy var rx_followedByCurrentUserLink: Observable<Link?> = {
        
        guard let reference = self.reference else { return Observable.empty() }
        
        return UserInfo.currentUserInfo.flatMap {  userInfo -> Observable<Link?> in
            
            return Link.rx_get(predicate: {
                $0.when(key: "fromUserReference", isEqualTo: userInfo!.reference! as AnyObject)
                    .filter(key: "toUserReference", isEqualTo: reference as AnyObject)
                    .filter(key: "kindRawValue", isEqualTo: Link.Kind.followUser.rawValue as AnyObject)
                })
                .map { $0.first }
                .shareReplay(1)
        }
        
    }()
}

extension UserInfo: AWSModelHasCreationDate {
    
    var followersCount: Int {
        get { return followersNumber?.intValue ?? 0 }
        set { followersNumber = NSNumber(value: newValue as Int) }
    }
    
    var followingCount: Int {
        get { return followingNumber?.intValue ?? 0 }
        set { followingNumber = NSNumber(value: newValue as Int) }
    }
    
    var likedCount: Int {
        get { return likedNumber?.intValue ?? 0 }
        set { likedNumber = NSNumber(value: newValue as Int) }
    }
    
    var postedCount: Int {
        get { return postedNumber?.intValue ?? 0 }
        set { postedNumber = NSNumber(value: newValue as Int) }
    }
    
    var rx_followerCount: Driver<Int> { return rx_count(key: "followersCount") }
    
    var rx_followingCount: Driver<Int> { return rx_count(key: "followingCount") }
    
    var rx_likedCount: Driver<Int> { return rx_count(key: "likedCount") }
    
    var rx_postedCount: Driver<Int> { return rx_count(key: "postedCount") }
    
    var imageURL: URL? { return imagePath.flatMap(URL.init) }
    
    var isMe: Bool {
        return userId == AWSIdentityManager.default().identityId!
    }
    
    func rx_followUser(_ follow: Bool) -> Observable<Link> {
        
        if follow {
            return Link.rx_insertFollowUserLink(to: self)
            //                .do(onNext: {  _ in self.likesCount += 1 }
        } else {
            return rx_followedByCurrentUserLink
                .filter { $0 != nil }
                .flatMap { $0!.rx_delete() }
            //                .do(onNext: {  _ in self.likesCount += -1 }
        }
    }
}

extension UserInfo: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-UserInfo"
    }
    
    static func hashKeyAttribute() -> String {
        return "userId"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationTime"
    }
}

extension UserInfo {
    
    convenience init(displayName: String?, imagePath: String?) {
        self.init()
        self.userId = AWSIdentityManager.default().identityId!
        self.creationTime = NSNumber.currentTimeNumber
        self.displayName = displayName
        self.followersNumber = 0
        self.followingNumber = 0
        self.likedNumber = 0
        self.postedNumber = 0
        self.imagePath = imagePath
    }
}

extension UserInfo {
    
    static var currentUserInfo: Observable<UserInfo?> {
        let manager = AWSIdentityManager.default()
        guard let userId = manager.identityId, manager.isLoggedIn == true else {
            return Observable.just(nil, scheduler: MainScheduler.instance)
        }
        
        switch cache.object(forKey: userId as NSString) {
        case let result?:
            return result
            
        default:
            let result = rx_get() {
                $0.when(key: "userId", isEqualTo: userId as AnyObject)
                }
                .map { $0.first }
                .shareReplay(1)
            
            cache.setObject(result, forKey: userId as NSString)
            
            return result
        }
        
    }
    
    fileprivate static let cache = NSCache<NSString, Observable<UserInfo?>>()
    
}


extension AWSIdentityManager {
    
    func rx_saveUserInfo() -> Observable<UserInfo> {
        return UserInfo(displayName: userName, imagePath: imageURL?.absoluteString)
            .rx_save()
    }
}



