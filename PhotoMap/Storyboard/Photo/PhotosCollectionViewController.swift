//
//  PhotosCollectionViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/30.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
        
    private func setupRx() {
        title = "加载中..."
        
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        collectionView?.rx_setDelegate(self)
        
        Photo.rx_getAll()
            .doOnError { [unowned self] error in self.title = "图片获取失败"; print(error) }
            .doOnCompleted { [unowned self] in self.title = "图片获取成功" }
            .bindTo(collectionView!.rx_itemsWithCellIdentifier("ImageCollectionViewCell", cellType: ImageCollectionViewCell.self)) { index, photo, cell in
                cell.update(with: photo)
            }.addDisposableTo(disposeBag)

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let bounds = UIScreen.mainScreen().bounds
        let width = (bounds.width - 30)/2 , height = width * 1.5
        return CGSize(width: width, height: height)
    }
}

extension Photo {
    
    static func rx_getAll() -> Observable<[Photo]> {
        return Observable.create{ observer in
            
            mapper.scan(self, expression: AWSDynamoDBScanExpression()) { output, error in
                
                switch (output?.items, error) {
                case let (_, error?):
                    observer.onError(error)
                case let (items?, _):
                    observer.onNext(items.map { $0 as! Photo })
                    observer.onCompleted()
                default: break
                }
            }
            
            return NopDisposable.instance
        }
        .observeOn(MainScheduler.instance)
    }
}

