//
//  Fundation+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import Foundation

extension Dictionary {
    
    init(keyValues: [(Key, Value)]) {
        self.init()
        for keyValue in keyValues {
            self[keyValue.0] = keyValue.1
        }
    }
}

extension NSNumber {
    
    static var currentTimeNumber: NSNumber {
        return  NSNumber(double: NSDate().timeIntervalSince1970)
    }
}