//
//  AWSIdentityManager+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import Foundation
import RxSwift
import RxCocoa
import AWSMobileHubHelper

extension AWSIdentityManager {
    
    func logout() {
        
        AWSIdentityManager.default().logout { (result, error) in
            print("rx_logout result:", result)
            print("rx_logout error:", error)
        }
        
//        return Observable.create({ (observer) -> Disposable in
//
//            AWSIdentityManager.defaultIdentityManager().logoutWithCompletionHandler { (result, error) in
//                print("rx_logout result:", result)
//                print("rx_logout error:", error)
//                switch error {
//                case let error?:
//                    observer.onError(error)
//                default:
//                    observer.onNext()
//                    observer.onCompleted()
//                }
//            }
//            
//            return Disposables.create()
//            
//        }).observeOn(MainScheduler.instance)
    }
}
