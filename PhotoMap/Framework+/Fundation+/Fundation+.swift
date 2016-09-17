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
        return  NSNumber(value: Date().timeIntervalSince1970 as Double)
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

extension Date {
    
    func toTimeIntervalNumber() -> NSNumber {
        return NSNumber(value: timeIntervalSince1970 as Double)
    }
    
    init(timeIntervalNumber: NSNumber) {
        self.init(timeIntervalSince1970: timeIntervalNumber.doubleValue)
    }
}


extension DateFormatter {
    
    static func string(from date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
