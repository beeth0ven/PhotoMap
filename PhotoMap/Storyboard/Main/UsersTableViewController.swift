//
//  UsersTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/12.
//
//

import UIKit

class UsersTableViewController: UITableViewController, HasMenuDetailController, DetailChildViewControllerType {
    
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
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        tableView?.rx_setDelegate(self)
        
//        UserInfo.rx_getAll()
        UserInfo.rx_get(references: [
            "[\"us-east-1:c78ba7fb-c24b-4757-9c8d-68e22a1e2159\",1471156438.289722]",
            "[\"us-east-1:dbf2ecae-5735-41d1-862a-a822d0ded00f\",1471156478.923095]"])
            .doOnError { [unowned self] error in self.title = "用户信息获取失败"; print(error) }
            .doOnCompleted { [unowned self] in self.title = "用户信息获取成功" }
            .bindTo(tableView!.rx_itemsWithCellIdentifier("UITableViewCell")) { index, userInfo, cell in
                cell.textLabel?.text        = userInfo.displayName
                cell.detailTextLabel?.text  = userInfo.userId
                cell.imageView?.rx_setImage(url: userInfo.imageURL)
            }.addDisposableTo(disposeBag)
        
    }
}
