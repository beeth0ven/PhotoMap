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
    
    static var sharedInstance = AWSUserDefaults(awsUserDefaults: AWSCognito.default().openOrCreateDataset("user_settings"))
    
    func rx_synchronize() -> Observable<AWSUserDefaults> {
        
        return awsUserDefaults.synchronize()
            .rx.result
            .map { _ in self }
        
    }
}

extension AWSCognitoDataset {
    
    func boolForKey(_ key: String) -> Bool {
        guard let string = string(forKey: key) else { return false }
        return string == "1"
    }
    
    func setBool(_ ifTrue: Bool, forKey key: String) {
        let string = ifTrue ? "1" : "0"
        setString(string, forKey: key)
    }
}
