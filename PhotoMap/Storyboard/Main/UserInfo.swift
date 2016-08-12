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
    var followersNumber: NSNumber?
    var displayName: String?
    var imagePath: String?
}

extension UserInfo {
    
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
        return "followersNumber"
    }
    
}

extension UserInfo {
    
    convenience init(displayName: String?, imagePath: String?) {
        self.init()
        self.userId = AWSIdentityManager.defaultIdentityManager().identityId!
        self.followersNumber = 0
        self.displayName = displayName
        self.imagePath = imagePath
        
        print("userId:", userId)
        print("followersNumber:", followersNumber)
        print("displayName:", displayName)
        print("imagePath:", imagePath)
    }
}

extension UserInfo {
    
    @nonobjc static let cache = NSCache()
    
    static func rx_get(userId userId: String) -> Observable<UserInfo?> {
        
        switch cache.objectForKey(userId) {
        case let result as Observable<UserInfo?>:
            print("new UserInfo from cache")
            return result
            
        default:
            print("new UserInfo from AWS")
            let predicate = AWSDynamoDBQueryExpression()
                .when(key: "userId", isEqualTo: userId)
            let result = rx_get(predicate: predicate).map { $0.first }.shareReplay(1)
            cache.setObject(result, forKey: userId)
            return result
        }
    }
    
    static func rx_get(userIds userIds: [String]) -> Observable<[UserInfo]> {
        
        let rx_userInfos = userIds.map { rx_get(userId: $0) }
        
        return rx_userInfos.combineLatest { userInfos in
            
            userInfos.flatMap { userInfo in userInfo }
            
            }.observeOn(MainScheduler.instance)
    }
}

extension AWSIdentityManager {
    
    func rx_saveUserInfo() -> Observable<UserInfo> {
        return UserInfo(displayName: userName, imagePath: imageURL?.absoluteString)
            .rx_save()
    }
}



