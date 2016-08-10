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
    
    func rx_logout() {
        
        AWSIdentityManager.defaultIdentityManager().logoutWithCompletionHandler { (result, error) in
            print("rx_logout result:", result)
            print("rx_logout error:", error)
        }
        
//        return Observable.create({ (obsever) -> Disposable in
//
//            AWSIdentityManager.defaultIdentityManager().logoutWithCompletionHandler { (result, error) in
//                print("rx_logout result:", result)
//                print("rx_logout error:", error)
//                switch error {
//                case let error?:
//                    obsever.onError(error)
//                default:
//                    obsever.onNext()
//                    obsever.onCompleted()
//                }
//            }
//            
//            return NopDisposable.instance
//            
//        }).observeOn(MainScheduler.instance)
    }
}