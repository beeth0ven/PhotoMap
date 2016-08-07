//
//  Phpto.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift

class Photo: AWSDynamoDBObjectModel {
    
    var userId: String?
    var creationDate: NSNumber?
    var imageS3Key: String?
    var title: String?
}


extension Photo: AWSDynamoDBModeling {
    
    static func dynamoDBTableName() -> String {
        return "photomap-mobilehub-567053031-Photo"
    }
    
    static func hashKeyAttribute() -> String {
        return "userId"
    }
    
    static func rangeKeyAttribute() -> String {
        return "creationDate"
    }
    
}


extension Photo {
    
    static func rx_insert(title title: String, image: UIImage) -> Observable<Photo> {
        
        return  image.rx_saveToS3()
            .map { key in Photo(title: title, imageS3Key: key) }
            .flatMap { $0.rx_save() }
    }

}

extension Photo {
    
    convenience init(title: String, imageS3Key: String) {
        self.init()
        self.userId = AWSIdentityManager.defaultIdentityManager().identityId!
        self.title = title
        self.imageS3Key = imageS3Key
        self.creationDate = NSNumber(double: NSDate().timeIntervalSince1970)
    }
}

