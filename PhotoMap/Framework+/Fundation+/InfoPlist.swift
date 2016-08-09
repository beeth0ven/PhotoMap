//
//  InfoPlist.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import Foundation

enum InfoPlist {
    
    static private let info = NSBundle.mainBundle().infoDictionary! as NSDictionary
    
    static func valueForKeyPath(keyPath: String) -> AnyObject? {
        return info.valueForKeyPath(keyPath)
    }
    
    static func setValue(value: AnyObject?, forKeyPath keyPath: String) {
        info.setValue(value, forKeyPath: keyPath)
    }
}