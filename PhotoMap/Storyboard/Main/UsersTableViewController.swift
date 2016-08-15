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
        
        UserInfo.rx_getAll()
        UserInfo.rx_get(references: [
            "[\"us-east-1:7982e028-e401-4dff-966b-af81de9fdb88\",1471233567.026141]",
            "[\"us-east-1:74a236f8-bac6-440f-8ff2-2c2a31c46c8b\",1471235499.02336]",
            "[\"us-east-1:fd3cfbd9-58cd-4cec-8fc0-beb8e5bb44d2\",1471233536.58108]"])
            .doOnError { [unowned self] error in self.title = "用户信息获取失败"; print(error) }
            .doOnCompleted { [unowned self] in self.title = "用户信息获取成功" }
            .bindTo(tableView!.rx_itemsWithCellIdentifier("UITableViewCell")) { index, userInfo, cell in
                cell.textLabel?.text        = userInfo.displayName
                cell.detailTextLabel?.text  = userInfo.userId
                cell.imageView?.rx_setImage(url: userInfo.imageURL)
            }.addDisposableTo(disposeBag)
        
    }
}
