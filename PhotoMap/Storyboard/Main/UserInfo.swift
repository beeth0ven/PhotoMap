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

extension AWSIdentityManager {
    
    func rx_saveUserInfo() -> Observable<UserInfo> {
        let manager = AWSIdentityManager.defaultIdentityManager()
        return UserInfo(displayName: manager.userName, imagePath: manager.imageURL?.absoluteString)
        .rx_save()
    }
}