//
//  AWSModelHasCreationDate.swift
//  PhotoMap
//
//  Created by luojie on 16/8/23.
//
//

import Foundation

protocol AWSModelHasCreationDate: NSObjectProtocol {
    
    var creationTime: NSNumber? { get set }
}

extension AWSModelHasCreationDate {
    
    var creationDate: NSDate? {
        get { return creationTime.flatMap(NSDate.init) }
        set { creationTime = newValue?.toTimeIntervalNumber() }
    }
}
