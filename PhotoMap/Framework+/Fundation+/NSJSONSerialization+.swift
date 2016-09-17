//
//  NSJSONSerialization+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/14.
//
//

import Foundation

extension JSONSerialization {
    
    static func parameters(from string: String) -> [AnyObject]? {
        if let
            data = string.data(using: String.Encoding.utf8),
            let parameters = (try? jsonObject(with: data, options: [])) as? [AnyObject] {
            return parameters
        }
        return nil
    }
    
    static func string(from parameters: [AnyObject]) -> String? {
        if let
            data = try? data(withJSONObject: parameters, options: []) {
            return String(data: data, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
}
