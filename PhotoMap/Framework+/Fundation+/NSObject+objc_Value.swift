//
//  NSObject+objc_Value.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import Foundation

extension NSObject {
    
    func objc_getValue(key key: UnsafePointer<Void>) -> AnyObject! {
        
        return objc_getAssociatedObject(self, key)
    }
    
    func objc_set(value value: AnyObject!, key: UnsafePointer<Void>, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        objc_setAssociatedObject(self, key, value, policy)
    }
}

