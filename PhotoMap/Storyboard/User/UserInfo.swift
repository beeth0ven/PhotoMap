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
    
}

extension UserInfo: AWSModelHasCreationDate {
    
    var followersCount: Int {
        get { return followersNumber?.integerValue ?? 0 }
        set { followersNumber = NSNumber(integer: newValue) }
    }
    
    var followingCount: Int {
        get { return followingNumber?.integerValue ?? 0 }
        set { followingNumber = NSNumber(integer: newValue) }
    }
    
    var likedCount: Int {
        get { return likedNumber?.integerValue ?? 0 }
        set { likedNumber = NSNumber(integer: newValue) }
    }
    
    var postedCount: Int {
        get { return postedNumber?.integerValue ?? 0 }
        set { postedNumber = NSNumber(integer: newValue) }
    }
    
    var imageURL: NSURL? { return imagePath.flatMap(NSURL.init) }
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
        self.userId = AWSIdentityManager.defaultIdentityManager().identityId!
        self.creationTime = NSNumber.currentTimeNumber
        self.displayName = displayName
        self.followersNumber = 0
        self.imagePath = imagePath
    }
}

extension UserInfo {
    
    static var currentUserInfo: Observable<UserInfo?> {
        let manager = AWSIdentityManager.defaultIdentityManager()
        guard let userId = manager.identityId where manager.loggedIn == true else {
            return Observable.just(nil, scheduler: MainScheduler.instance)
        }
        
        switch cache.objectForKey(userId) {
        case let result  as Observable<UserInfo?>:
            return result
            
        default:
            let predicate = AWSDynamoDBQueryExpression()
                .when(key: "userId", isEqualTo: userId)
            
            let result = rx_get(predicate: predicate)
                .map { $0.first }
                .shareReplay(1)
            
            cache.setObject(result, forKey: userId)
            
            return result
        }

    }
    
    private static let cache = NSCache()
    
}


extension AWSIdentityManager {
    
    func rx_saveUserInfo() -> Observable<UserInfo> {
        return UserInfo(displayName: userName, imagePath: imageURL?.absoluteString)
            .rx_save()
    }
}



