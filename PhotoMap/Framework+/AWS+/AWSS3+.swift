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
            switch objc_getValue(key: &AssociatedKeys.s3_setImageDisposeBag) {
            case let result as DisposeBag:
                return result
            default:
                let result = DisposeBag()
                objc_set(value: result, key: &AssociatedKeys.s3_setImageDisposeBag)
                return result
            }
        }
        set {
            objc_set(value: disposeBag, key: &AssociatedKeys.s3_setImageDisposeBag)
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
            
            content.downloadWithDownloadType(.IfNotCached, pinOnCompletion: true, progressBlock: { _, progress in print("progressBlock", progress.percent) }) { _, data, error in
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

            content.uploadWithPinOnCompletion(true, progressBlock: { _, progress in print("progressBlock", progress.percent) }) { (_, error) in
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

extension String {
    
    func toS3URL(s3bucket s3bucket: String = InfoPlist.s3Bucket!) -> NSURL? {
        let path = "https://s3.amazonaws.com/\(s3bucket)/\(self)"
        return NSURL(string: path)
    }
}

extension InfoPlist {
    
    static var s3Bucket: String? {
        return valueForKeyPath("AWS.UserFileManager.Default.S3Bucket") as? String
    }
}

extension NSProgress {
    
    var percent: String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .PercentStyle
        return formatter.stringFromNumber(NSNumber(double: fractionCompleted))!
    }
}

