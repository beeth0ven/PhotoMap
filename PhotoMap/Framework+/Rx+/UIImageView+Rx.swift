//
//  UIImageView+Rx.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    
    static private let cache = NSCache()
    
    func rx_setImage(url url: NSURL?, placeholder: UIImage? = nil) {

        rx_setImageDisposeBag = DisposeBag()
        image = placeholder
        guard let url = url else { return }
        
        if let data = UIImageView.cache.objectForKey(url.absoluteString) as? NSData, cachedImage = UIImage(data: data) {
            image = cachedImage
        } else {
            NSURLSession.sharedSession().rx_data(url: url)
                .observeOn(MainScheduler.instance)
                .doOnError { error in print(error) }
                .subscribeNext { [unowned self] data in
                    if let image = UIImage(data: data) {
                        UIImageView.cache.setObject(data, forKey: url.absoluteString)
                        self.image = image
                    } else {
                        print("Data can not be converted to image!")
                    }
                }
                .addDisposableTo(rx_setImageDisposeBag)
        }
        
    }
    
    private var rx_setImageDisposeBag: DisposeBag {
        get {
            if let disposeBag = objc_getAssociatedObject(self, &AssociatedKeys.rx_setImageDisposeBag) as? DisposeBag {
                return disposeBag
            }
            let disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.rx_setImageDisposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rx_setImageDisposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private enum AssociatedKeys {
        static var rx_setImageDisposeBag = "rx_setImageDisposeBag"
    }
}

extension NSURLSession {
    
    func rx_data(url url: NSURL) -> Observable<NSData> {
        let request = NSURLRequest(URL: url)
        return rx_data(request)
    }
}