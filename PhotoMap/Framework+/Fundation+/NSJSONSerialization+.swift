//
//  NSJSONSerialization+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/14.
//
//

import Foundation

extension NSJSONSerialization {
    
    static func parameters(from string: String) -> [String: AnyObject]? {
        if let
            data = string.dataUsingEncoding(NSUTF8StringEncoding),
            parameters = try? JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            return parameters
        }
        return nil
    }
    
    static func string(from parameters: [String: AnyObject]) -> String? {
        if let
            data = try? dataWithJSONObject(parameters, options: []) {
            return String(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
}
