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
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
    func rx_delete() -> Observable<Self> {
        
        return Observable.create { observer in
            
            Self.mapper.remove(self) { error in
                switch error {
                case let error?:
                    observer.onError(error)
                case nil:
                    observer.onNext(self)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
            
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
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
    static func rx_get(predicate: ((AWSDynamoDBQueryExpression) -> Void)) -> Observable<[Self]> {
        
        let expression = AWSDynamoDBQueryExpression()
        predicate(expression)
        
        return Observable.create { observer in
            mapper.query(self, expression: expression) { (output, error) in
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
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
    static func rx_get(hashValue: AnyObject, rangeValue: AnyObject? = nil) -> Observable<Self?> {
        
        let rangeDescription = rangeValue?.description ?? ""
        let cacheKey = String(describing: self) + "/" + hashValue.description! + "/" + rangeDescription
        
        switch cache.object(forKey: cacheKey as NSString) {
        case let result as Observable<Self?>:
            print(String(describing: self), "from cache.")
            return result
        default:
            print(String(describing: self), "from AWS.")
            
            let result =  mapper.load(self, hashKey: hashValue, rangeKey: rangeValue)
                .rx.result
                .do(onError: { print("mapper.load.error:", $0) })
                .map { $0 as? Self }
                .shareReplay(1)
                .observeOn(MainScheduler.instance)
            
            cache.setObject(result, forKey: cacheKey as NSString)
            return result
        }
    }
    
    static func rx_get(reference: String?) -> Observable<Self?> {
        guard let reference = reference, let parameters = JSONSerialization.parameters(from: reference), let hashValue = parameters.element(at: 0) else {
            return Observable.just(nil, scheduler: MainScheduler.instance)
        }
        return rx_get(hashValue: hashValue, rangeValue: parameters.element(at: 1))
    }
    
    static func rx_get(references: [String]) -> Observable<[Self]> {
        
        guard references.count > 0 else {
            return Observable.just([], scheduler: MainScheduler.instance)
        }
        
        let rx_models = references.map { rx_get(reference: $0) }
        
        return rx_models.combineLatest { models in
            
            models.flatMap { model in model }
            
            }.observeOn(MainScheduler.instance)
    }
    
    var reference: String? {
        
        let hashKey = type(of: self).hashKeyAttribute(), rangeKey = type(of: self).rangeKeyAttribute?()
        
        switch (value(forKey: hashKey), rangeKey) {
        case let (hashValue?, nil):
            return JSONSerialization.string(from: [hashValue as AnyObject])
        case let (hashValue?, rangeKey?):
            let rangeValue = value(forKey: rangeKey)
            return rangeValue.flatMap { JSONSerialization.string(from: [hashValue as AnyObject, $0 as AnyObject]) }
        default:
            return nil
        }
        
    }
    
    static var mapper: AWSDynamoDBObjectMapper {
        return AWSDynamoDBObjectMapper.default()
    }
}

private let cache = NSCache<NSString, AnyObject>()


