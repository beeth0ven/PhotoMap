//
//  NSURL+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import Foundation

extension NSURL {
    
    static func string(from parameters: [String: String]) -> String? {
        let items = parameters.map { NSURLQueryItem(name: $0, value: $1) }
        let components = NSURLComponents()
        components.queryItems = items
        return components.URL?.absoluteString
    }
    
    static func parameters(from string: String) -> [String: String] {
        let items = NSURLComponents(string: string)?.queryItems?.map { ($0.name, $0.value!) } ?? []
        return Dictionary(keyValues: items)
    }
}