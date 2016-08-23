//
//  AWSDynamoDBObjectModelType.swift
//  PhotoMap
//
//  Created by luojie on 16/8/14.
//
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift

protocol AWSDynamoDBObjectModelType {}

extension AWSDynamoDBObjectModel: AWSDynamoDBObjectModelType {}

extension AWSDynamoDBObjectModelType where Self: AWSDynamoDBObjectModel, Self: AWSDynamoDBModeling {
    
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
    
    static func rx_get(hashValue hashValue: AnyObject, rangeValue: AnyObject? = nil) -> Observable<Self?> {
        
        let cacheKey = String(self) + "/" + hashValue.description! + "/" + (rangeValue?.description ?? "")
        
        switch cache.objectForKey(cacheKey) {
        case let result as Observable<Self?>:
            print(String(self), "from cache.")
            return result
        default:
            print(String(self), "from AWS.")
            
            let result =  mapper.load(self, hashKey: hashValue, rangeKey: rangeValue)
                .rx_result
                .doOnError { print("mapper.load.error:", $0) }
                .map { $0 as? Self }
                .shareReplay(1)
                .observeOn(MainScheduler.instance)
            
            cache.setObject(result, forKey: cacheKey)
            return result
        }
    }
    
//    static func rx_get(hashValues hashValues: [String]) -> Observable<[Self]> {
//        let _references: [(hashValue: AnyObject, rangeValue: AnyObject?)] = hashValues.map { ($0, nil) }
//        return rx_get(_references: _references)
//    }
//    
//    
//    static func rx_get(references references: [(hashValue: AnyObject, rangeValue: AnyObject)]) -> Observable<[Self]> {
//        let _references: [(hashValue: AnyObject, rangeValue: AnyObject?)] = references.map { ($0.hashValue, $0.rangeValue) }
//        return rx_get(_references: _references)
//    }
    
//    private static func rx_get(_references _references: [(hashValue: AnyObject, rangeValue: AnyObject?)]) -> Observable<[Self]> {
//        
//        let rx_models = _references.map { rx_get(hashValue: $0.hashValue, rangeValue: $0.rangeValue) }
//        
//        return rx_models.combineLatest { models in
//            
//            models.flatMap { model in model }
//            
//            }.observeOn(MainScheduler.instance)
//    }
    
    static func rx_get(reference reference: String?) -> Observable<Self?> {
        guard let reference = reference, parameters = NSJSONSerialization.parameters(from: reference), hashValue = parameters.element(at: 0) else {
            return Observable.just(nil, scheduler: MainScheduler.instance)
        }
        return rx_get(hashValue: hashValue, rangeValue: parameters.element(at: 1))
    }
    
    static func rx_get(references references: [String]) -> Observable<[Self]> {
        
        let rx_models = references.map { rx_get(reference: $0) }
        
        return rx_models.combineLatest { models in
            
            models.flatMap { model in model }
            
            }.observeOn(MainScheduler.instance)
    }
    
    var reference: String? {
        
        let hashKey = self.dynamicType.hashKeyAttribute(), rangeKey = self.dynamicType.rangeKeyAttribute?()
        
        switch (valueForKey(hashKey), rangeKey) {
        case let (hashValue?, nil):
            return NSJSONSerialization.string(from: [hashValue])
        case let (hashValue?, rangeKey?):
            let rangeValue = valueForKey(rangeKey)
            return rangeValue.flatMap { NSJSONSerialization.string(from: [hashValue, $0]) }
        default:
            return nil
        }
        
    }
    
    static var mapper: AWSDynamoDBObjectMapper {
        return AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    }
    
    
}

private let cache = NSCache()
