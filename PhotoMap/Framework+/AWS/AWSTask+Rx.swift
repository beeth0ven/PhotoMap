//
//  AWSTask+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/8.
//
//

import Foundation
import AWSMobileHubHelper
import RxSwift
import RxCocoa

extension AWSTask {
    
    var rx_result: Observable<AnyObject?> {
        
        return Observable.create { (observer) -> Disposable in
            
            self.continueWithBlock { task -> AnyObject? in
                
                switch task.error {
                case let error?:
                    observer.onError(error)
                default:
                    observer.onNext(task.result)
                    observer.onCompleted()
                }
                
                return nil
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
}
