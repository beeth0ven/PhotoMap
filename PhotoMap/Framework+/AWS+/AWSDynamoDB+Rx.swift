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
    
    static var mapper: AWSDynamoDBObjectMapper {
        return AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    }
}
