//
//  AWSTask+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/8.
//
//

import Foundation
import AWSMobileHubHelper
import AWSCognitoIdentityProvider
import RxSwift
import RxCocoa

extension Reactive where Base: AWSTask<AnyObject> {
    
    var result: Observable<AnyObject?> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.base.continue({ task -> Any? in
                
                switch task.error {
                case let error?:
                    observer.onError(error)
                default:
                    observer.onNext(task.result)
                    observer.onCompleted()
                }
                
                return nil
            })
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }

}



extension Reactive where Base: AWSTask<AWSCognitoIdentityUserSession> {
    
    var result: Observable<AWSCognitoIdentityUserSession?> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.base.continue({ task -> Any? in
                
                switch task.error {
                case let error?:
                    observer.onError(error)
                default:
                    observer.onNext(task.result)
                    observer.onCompleted()
                }
                
                return nil
            })
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
}
