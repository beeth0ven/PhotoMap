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

extension Array {
    
    func element(at index: Index) -> Element? {
        guard startIndex <= index && index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}

extension NSDate {
    
    func toTimeIntervalNumber() -> NSNumber {
        return NSNumber(double: timeIntervalSince1970)
    }
    
    convenience init(timeIntervalNumber: NSNumber) {
        self.init(timeIntervalSince1970: timeIntervalNumber.doubleValue)
    }
}


extension NSDateFormatter {
    
    static func string(from date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
}