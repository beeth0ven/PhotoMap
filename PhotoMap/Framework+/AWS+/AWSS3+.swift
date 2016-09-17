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
    
    func s3_setImage(key: String?, placeholder: UIImage? = nil) {
        s3_setImageDisposeBag = DisposeBag()
        image = placeholder
        guard let key = key else { return }
        UIImage.rx_getFromS3(key: key)
            .do(onError: { error in print(error) })
            .subscribe(onNext: { [unowned self] image in self.image = image })
            .addDisposableTo(s3_setImageDisposeBag)
        
    }
    
    fileprivate var s3_setImageDisposeBag: DisposeBag {
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
    
    fileprivate enum AssociatedKeys {
        static var s3_setImageDisposeBag = "s3_setImageDisposeBag"
    }
}

protocol S3DataConvertible {
    init?(data: Data)
    func toData() -> Data?
    var extensionName: String { get }
}

extension S3DataConvertible {
    
    static func rx_getFromS3(key: String) -> Observable<Self> {
        
        return Observable.create { observer in
            
            let manager = AWSMobileHubHelper.AWSUserFileManager.default() as AWSUserFileManager
            let content = manager.content(withKey: key)
            
            content.download(with: .ifNotCached, pinOnCompletion: true, progressBlock: { _, progress in print("progressBlock", progress.percent) }) { _, data, error in
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
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
    func rx_saveToS3() -> Observable<String> {
        
        return Observable.create { observer in
            
            let manager = AWSMobileHubHelper.AWSUserFileManager.default()
            let data = self.toData()
            
            let filename = NSDate().timeIntervalSince1970.description + self.extensionName, key = "public/\(filename)"
            
            let content = manager.localContent(with: data, key: key)

            content.uploadWithPin(onCompletion: true, progressBlock: { _, progress in print("progressBlock", progress.percent) }) { (_, error) in
                switch error {
                case let error?:
                    observer.onError(error)
                case nil:
                    observer.onNext(key)
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
            
            }.observeOn(MainScheduler.instance)
    }
    
    var extensionName: String { return "" }
}

extension UIImage: S3DataConvertible {
    
    func toData() -> Data? {
        return UIImageJPEGRepresentation(self, 0.1)
    }
    
    var extensionName: String {
        return ".png"
    }
}

extension String {
    
    func toS3URL(s3bucket: String = InfoPlist.s3Bucket!) -> URL? {
        let path = "https://s3.amazonaws.com/\(s3bucket)/\(self)"
        return URL(string: path)
    }
}

extension InfoPlist {
    
    static var s3Bucket: String? {
        return valueForKeyPath("AWS.UserFileManager.Default.S3Bucket") as? String
    }
}

extension Progress {
    
    var percent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter.string(from: NSNumber(value: fractionCompleted as Double))!
    }
}

