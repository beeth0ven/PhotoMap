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
    
    static fileprivate let cache = NSCache<NSString, NSData>()
    
    func rx_setImage(url: URL?, placeholder: UIImage? = nil) {

        rx_setImageDisposeBag = DisposeBag()
        image = placeholder
        guard let url = url else { return }
        
        if let data = UIImageView.cache.object(forKey: url.absoluteString as NSString) as? Data, let cachedImage = UIImage(data: data) {
            image = cachedImage
        } else {
            URLSession.shared.rx.data(url: url)
                .observeOn(MainScheduler.instance)
                .do(onError: { error in print(error) })
                .subscribe(onNext: { [unowned self] data in
                    if let image = UIImage(data: data) {
                        UIImageView.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                        self.image = image
                    } else {
                        print("Data can not be converted to image!")
                    }
                })
                .addDisposableTo(rx_setImageDisposeBag)
        }
        
    }
    
    fileprivate var rx_setImageDisposeBag: DisposeBag {
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
    
    fileprivate enum AssociatedKeys {
        static var rx_setImageDisposeBag = "rx_setImageDisposeBag"
    }
}


extension Reactive where Base: URLSession {
    
    func data(url: URL) -> Observable<Data> {
        let request = URLRequest(url: url)
        return data(request)
    }
}
