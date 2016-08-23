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
    
    @IBOutlet weak var toggleMenuBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
        
    private func setupRx() {
        rx_bindDataSource()
        rx_bindToggleShowMenu()
    }
    
    func rx_bindDataSource() {
        title = "加载中..."
        
        collectionView?.dataSource = nil
        collectionView?.delegate = nil
        collectionView?.rx_setDelegate(self)
        
        Photo.rx_getAll()
            .doOnError { [unowned self] error in self.title = "图片获取失败"; print(error) }
            .doOnCompleted { [unowned self] in self.title = "图片获取成功" }
            .bindTo(collectionView!.rx_itemsWithCellIdentifier("ImageCollectionViewCell", cellType: ImageCollectionViewCell.self)) { index, photo, cell in
                cell.photo = photo
            }.addDisposableTo(disposeBag)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let bounds = UIScreen.mainScreen().bounds
        let width = (bounds.width - 30)/2 , height = width * 1.6
        return CGSize(width: width, height: height)
    }
}

extension PhotosCollectionViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "ShowPhoto"?:
            let vc = segue.destinationViewController as! PhotoDetailTableViewController,
            cell = sender as! ImageCollectionViewCell
            vc.photo = cell.photo
            
        default:
            break
        }
    }
}



