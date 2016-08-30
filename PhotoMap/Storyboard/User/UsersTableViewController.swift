//
//  UsersTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import UIKit
import RxSwift
import RxCocoa

class UsersTableViewController: UITableViewController{
    
    var rx_getData: Observable<[UserInfo]>! = UserInfo.rx_getAll()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    private func setupRx() {
        rx_bindDataSource()
    }
    
    func rx_bindDataSource() {
        
        title = "加载中..."
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        tableView?.rx_setDelegate(self)
        
        rx_getData
            .doOnError { [unowned self] error in self.title = "用户信息获取失败"; print(error) }
            .doOnNext { [unowned self] _ in self.title = "用户信息获取成功" }
            .bindTo(tableView!.rx_itemsWithCellIdentifier("UITableViewCell")) { index, userInfo, cell in
                cell.textLabel?.text        = userInfo.displayName
                cell.detailTextLabel?.text  = userInfo.userId
                cell.imageView?.rx_setImage(url: userInfo.imageURL)
            }.addDisposableTo(disposeBag)
        
    }
}
