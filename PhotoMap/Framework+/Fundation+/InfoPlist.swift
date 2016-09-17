//
//  InfoPlist.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import Foundation

enum InfoPlist {
    
    static fileprivate let info = Bundle.main.infoDictionary! as NSDictionary
    
    static func valueForKeyPath(_ keyPath: String) -> AnyObject? {
        return info.value(forKeyPath: keyPath) as AnyObject?
    }
    
    static func setValue(_ value: AnyObject?, forKeyPath keyPath: String) {
        info.setValue(value, forKeyPath: keyPath)
    }
}
