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

protocol AWSDynamoDBObjectModelType {}
extension AWSDynamoDBObjectModel: AWSDynamoDBObjectModelType {}
extension AWSDynamoDBObjectModelType where Self: AWSDynamoDBObjectModel {
    
    func rx_save() -> Observable<Self> {
        
        return Observable.create { observer in
            
            Self.mapper.save(self) { error in
                switch error {
                case let error?:
                    observer.onError(error)
                case nil:
                    observer.onNext(self)
                    observer.onCompleted()
                }
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
    
    static func rx_getAll() -> Observable<[Self]> {
        
        return Observable.create { observer in
            
            mapper.scan(self, expression: AWSDynamoDBScanExpression()) { output, error in
                
                switch (output?.items, error) {
                case let (_, error?):
                    observer.onError(error)
                case let (items?, _):
                    let result = items as! [Self]
                    observer.onNext(result)
                    observer.onCompleted()
                default: break
                }
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
    
    static func rx_get(predicate predicate: AWSDynamoDBQueryExpression) -> Observable<[Self]> {
        
        return Observable.create { observer in
            
            mapper.query(self, expression: predicate) { (output, error) in
                switch (output?.items, error) {
                case let (_, error?):
                    observer.onError(error)
                case let (items?, _):
                    let result = items as! [Self]
                    observer.onNext(result)
                    observer.onCompleted()
                default: break
                }
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
    
    static func rx_get(hashKey hashKey: AnyObject, rangeKey: AnyObject? = nil) -> Observable<Self?> {
        
        return mapper.load(self, hashKey: hashKey, rangeKey: rangeKey)
            .rx_result
            .map { $0 as? Self }
    }
    
    static var mapper: AWSDynamoDBObjectMapper {
        return AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    }
}


extension AWSDynamoDBQueryExpression {
    
    func when(key key: String, isEqualTo object: AnyObject) -> AWSDynamoDBQueryExpression {
        keyConditionExpression = "#\(key) = :\(key)"
        expressionAttributeNames = ["#\(key)": "\(key)",]
        expressionAttributeValues = [":\(key)": object]
        return self
    } 
}
