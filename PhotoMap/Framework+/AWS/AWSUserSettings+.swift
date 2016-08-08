//
//  AWSUserSettings+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/8.
//
//

import UIKit
import AWSCore
import AWSCognito

struct UserSetting: AWSUserSettingType {
    
    static var standardUserSetting = UserSetting(awsUserDefaults: AWSCognito.defaultCognito().openOrCreateDataset("user_settings"))
    
    var awsUserDefaults: AWSCognitoDataset
    
    var isUserInfoSetted: Bool {
        get { return awsUserDefaults.boolForKey("isUserInfoSetted") }
        set { awsUserDefaults.setBool(newValue, forKey: "isUserInfoSetted") }
    }
    
    func synchronize(didSynchronize didSynchronize: (UserSetting) -> Void, didFail: ((NSError) -> Void)? = nil) {
        
        awsUserDefaults.synchronize().continueWithBlock { (task) -> AnyObject? in
            
            switch (task.result, task.error) {
            case let (_, error?):
                Queue.Main.execute { didFail?(error) }
            case (_?, _):
                Queue.Main.execute { didSynchronize(self) }
            default: break
            }
            
            return nil
        }
    }
}


protocol AWSUserSettingType {
    static var standardUserSetting: Self { get set }
}

extension AWSCognitoDataset {
    
    func boolForKey(key: String) -> Bool {
        return stringForKey("isUserInfoSetted") == "1"
    }
    
    func setBool(bool: Bool, forKey key: String) {
        let string = bool ? "1" : "0"
        setString(string, forKey: string)
    }
}