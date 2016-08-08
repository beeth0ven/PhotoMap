//
//  AWSUserDefaults+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/8.
//
//

import UIKit
import AWSCore
import AWSCognito
import RxSwift
import RxCocoa

struct AWSUserDefaults {
    
    let awsUserDefaults: AWSCognitoDataset
}

extension AWSUserDefaults {
    
    static var sharedInstance = AWSUserDefaults(awsUserDefaults: AWSCognito.defaultCognito().openOrCreateDataset("user_settings"))
    
    func rx_synchronize() -> Observable<AWSUserDefaults> {
        
        return awsUserDefaults.synchronize()
            .rx_result
            .map { _ in self }
        
    }
}

extension AWSCognitoDataset {
    
    func boolForKey(key: String) -> Bool {
        guard let string = stringForKey(key) else { return false }
        return string == "1"
    }
    
    func setBool(ifTrue: Bool, forKey key: String) {
        let string = ifTrue ? "1" : "0"
        setString(string, forKey: key)
    }
}
