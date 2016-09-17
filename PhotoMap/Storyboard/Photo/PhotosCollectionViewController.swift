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

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HasMenuDetailController, DetailChildViewControllerType {
    
    @IBOutlet var toggleMenuBarButtonItem: UIBarButtonItem!
    var rx_getData: Observable<[Photo]>! = Photo.rx_getAll()
    
    let photos = Variable([Photo]())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
        
    fileprivate func setupRx() {
        rx_bindDataSource()
        rx_bindToggleShowMenu()
    }
    
    func rx_bindDataSource() {
        title = "加载中..."
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        collectionView?.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        observe(for: .AWSIdentityManagerDidSignIn)
            .throttle(0.5, scheduler: MainScheduler.instance)
            .flatMap { [unowned self] _ in self.rx_getData }
            .do(onError: { [unowned self] error in self.title = "图片获取失败"; print(error) })
            .do(onCompleted: { [unowned self] in self.title = "图片获取成功" })
            .bindTo(photos)
            .addDisposableTo(disposeBag)
        
        photos.asDriver()
            .drive(collectionView!.rx.items(cellIdentifier: "ImageCollectionViewCell", cellType: ImageCollectionViewCell.self)) { index, photo, cell in
                cell.photo = photo
            }.addDisposableTo(disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30)/2 , height = width * 1.6
        return CGSize(width: width, height: height)
    }
}

extension PhotosCollectionViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "UploadPhoto"?:
            let vc = segue.destination as! UploadPhotoTableViewController
            vc.rx_photo
                .drive(onNext: { [unowned self] in self.photos.value.insert($0, at: 0) })
                .addDisposableTo(disposeBag)

            
        case "ShowPhoto"?:
            let vc = segue.destination as! PhotoDetailTableViewController,
            cell = sender as! ImageCollectionViewCell
            vc.photo = cell.photo
            
        default:
            break
        }
    }
}



