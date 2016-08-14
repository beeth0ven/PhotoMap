//
//  AWSDynamoDB+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/7.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift

extension AWSDynamoDBQueryExpression {
    
    func when(key key: String, isEqualTo object: AnyObject) -> AWSDynamoDBQueryExpression {
        
        switch keyConditionExpression {
        case nil:
            keyConditionExpression = "#\(key) = :\(key)"
        default:
            keyConditionExpression! += " AND #\(key) = :\(key)"
        }
        
        switch expressionAttributeNames {
        case nil:
            expressionAttributeNames = ["#\(key)": "\(key)",]
        default:
            expressionAttributeNames!["#\(key)"] = "\(key)"

        }
        
        switch expressionAttributeValues {
        case nil:
            expressionAttributeValues = [":\(key)": object]
        default:
            expressionAttributeValues![":\(key)"] = object
        }
        
        return self
    }
    
//    func when(reference reference: String) -> AWSDynamoDBQueryExpression {
//        
//        let matches = NSURL.parameters(from: reference)
//
//        matches.forEach { key, value in
//            when(key: key, isEqualTo: value)
//        }
//        
//        return self
//    }
    
}

