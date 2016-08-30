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
import RxCocoa

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
    
    func filter(key key: String, isEqualTo object: AnyObject) -> AWSDynamoDBQueryExpression {
        
        switch filterExpression {
        case nil:
            filterExpression = "#\(key) = :\(key)"
        default:
            filterExpression! += " AND #\(key) = :\(key)"
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
}


protocol AWSHasTableIndex {
    associatedtype IndexIdentifier: RawRepresentable
}

extension AWSHasTableIndex where
    Self: AWSDynamoDBObjectModelType,
    Self: AWSDynamoDBObjectModel,
    Self: AWSDynamoDBModeling,
    Self.IndexIdentifier.RawValue == String {
    
    static func rx_get(indexIdentifier indexIdentifier: IndexIdentifier, predicate: ((AWSDynamoDBQueryExpression) -> Void)) -> Observable<[Self]> {
        let newPredicate = { (expression: AWSDynamoDBQueryExpression) -> Void in
            expression.indexName = indexIdentifier.rawValue
            predicate(expression)
        }
        return rx_get(predicate: newPredicate)
    }
    
}

extension AWSDynamoDBObjectModel {
    
    func rx_count(key key: String) -> Driver<Int> {
        
        return rx_observe(Int.self, key)
            .map { $0! }
            .asDriver(onErrorDriveWith: Driver.empty())
    }
}

