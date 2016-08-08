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

struct AWSUserDefaults {
    
    private let awsUserDefaults: AWSCognitoDataset
}

extension AWSUserDefaults {
    
    static func standardUserDefaults() -> AWSUserDefaults {
        return self.init(awsUserDefaults: AWSCognito.defaultCognito().openOrCreateDataset("user_settings"))
    }
    
    func synchronize(didSynchronize didSynchronize: (AWSUserDefaults) -> Void, didFail: ((NSError) -> Void)? = nil) {
        
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

extension AWSCognitoDataset {
    
    func boolForKey(key: String) -> Bool {
        return stringForKey("isUserInfoSetted") == "1"
    }
    
    func setBool(bool: Bool, forKey key: String) {
        let string = bool ? "1" : "0"
        setString(string, forKey: string)
    }
}

extension AWSUserDefaults {
    var isUserInfoSetted: Bool {
        get { return awsUserDefaults.boolForKey("isUserInfoSetted") }
        set { awsUserDefaults.setBool(newValue, forKey: "isUserInfoSetted") }
    }
}