//
//  AWSS3+.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import AWSS3
import AWSMobileHubHelper
import RxSwift
import RxCocoa

extension UIImageView {
    
    func s3_setImage(key key: String?, placeholder: UIImage? = nil) {
        s3_setImageDisposeBag = DisposeBag()
        image = placeholder
        guard let key = key else { return }
        UIImage.rx_getFromS3(key: key)
            .doOnError { error in print(error) }
            .subscribeNext { [unowned self] image in self.image = image }
            .addDisposableTo(s3_setImageDisposeBag)
        
    }
    
    private var s3_setImageDisposeBag: DisposeBag {
        get {
            if let disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.s3_setImageDisposeBag) as? DisposeBag {
                return disposeBag
            }
            let disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.s3_setImageDisposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.s3_setImageDisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private enum AssociatedKeys {
        static var s3_setImageDisposeBag = "s3_setImageDisposeBag"
    }
}

protocol S3DataConvertible {
    init?(data: NSData)
    func toData() -> NSData?
    var extensionName: String { get }
}

extension S3DataConvertible {
    
    static func rx_getFromS3(key key: String) -> Observable<Self> {
        
        return Observable.create { observer in
            
            let manager = AWSUserFileManager.defaultUserFileManager()
            let content = manager.contentWithKey(key)
            
            content.downloadWithDownloadType(.IfNotCached, pinOnCompletion: true, progressBlock: { _, _ in print("progressBlock") }) { _, data, error in
                switch (error, data) {
                case let (error?, _):
                    observer.onError(error)
                case let (_, data?):
                    if let result = self.init(data: data) {
                        observer.onNext(result)
                        observer.onCompleted()
                    } else {
                        let error = NSError(domain: "AWSS3", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data type not match!"])
                        observer.onError(error)
                    }
                default: break
                }
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
    
    func rx_saveToS3() -> Observable<String> {
        
        return Observable.create { observer in
            
            let manager = AWSUserFileManager.defaultUserFileManager()
            
            let data = self.toData()
            
            let filename = NSDate().timeIntervalSince1970.description + self.extensionName, key = "public/\(filename)"
            
            let content = manager.localContentWithData(data, key: key)
            
            content.uploadWithPinOnCompletion(true, progressBlock: { _, _ in print("progressBlock") }) { (_, error) in
                switch error {
                case let error?:
                    observer.onError(error)
                case nil:
                    observer.onNext(key)
                    observer.onCompleted()
                }
            }
            
            return NopDisposable.instance
            
            }.observeOn(MainScheduler.instance)
    }
    
    var extensionName: String { return "" }
}

extension UIImage: S3DataConvertible {
    
    func toData() -> NSData? {
        return UIImageJPEGRepresentation(self, 0.1)
    }
    
    var extensionName: String {
        return ".png"
    }
}