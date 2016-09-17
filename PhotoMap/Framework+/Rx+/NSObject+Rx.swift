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
    
    func observe(for name: Notification.Name) -> Observable<Notification> {
        return NotificationCenter.default.rx.notification(name)
    }
    
    func postNotification(for name: Notification.Name, object: AnyObject? = nil, userInfo: [AnyHashable: Any]? = nil) {
        let object = object ?? self
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
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
    
    fileprivate enum AssociatedKeys {
        static var disposeBag = "disposeBag"
    }
}
