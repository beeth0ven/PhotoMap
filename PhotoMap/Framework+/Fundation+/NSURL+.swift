//
//  NSURL+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import Foundation

extension URL {
    
    static func string(from parameters: [String: String]) -> String? {
        let items = parameters.map { URLQueryItem(name: $0, value: $1) }
        var components = URLComponents()
        components.queryItems = items
        return components.url?.absoluteString
    }
    
    static func parameters(from string: String) -> [String: String] {
        let items = URLComponents(string: string)?.queryItems?.map { ($0.name, $0.value!) } ?? []
        return Dictionary(keyValues: items)
    }
}
