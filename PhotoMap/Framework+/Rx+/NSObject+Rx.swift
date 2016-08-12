//
//  NSObject+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import Foundation
import RxSwift
import RxCocoa


extension NSObject {
    
    func observe(for name: String) -> Observable<NSNotification> {
        return NSNotificationCenter.defaultCenter().rx_notification(name)
    }
    
    func postNotification(for name: String, object: AnyObject? = nil, userInfo: [NSObject : AnyObject]? = nil) {
        let object = object ?? self
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: object, userInfo: userInfo)
    }
}


extension NSObject {
    
    var disposeBag: DisposeBag {
        
        switch objc_getValue(key: &AssociatedKeys.disposeBag) {
        case let disposeBag as DisposeBag:
            return disposeBag
        default:
            let disposeBag = DisposeBag()
            objc_set(value: disposeBag, key: &AssociatedKeys.disposeBag)
            return disposeBag
        }
    }
    
    private enum AssociatedKeys {
        static var disposeBag = "disposeBag"
    }
}
