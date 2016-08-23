//
//  PhotoDetailTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/23.
//
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class PhotoDetailTableViewController: UITableViewController {
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    private func setupRx() {
        
        title = "加载中..."
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        
        photo.recentComments
            .doOnError { [unowned self] error in self.title = "评论获取失败"; print(error) }
            .doOnCompleted { [unowned self] in self.title = "评论获取成功" }
            .bindTo(tableView!.rx_itemsWithCellIdentifier("UITableViewCell")) { index, comment, cell in
                cell.textLabel?.text = comment.creationDate.flatMap(NSDateFormatter.string)
                cell.detailTextLabel?.text = comment.content
            }.addDisposableTo(disposeBag)

    }
    
}

extension PhotoDetailTableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "AddComment"?:
            let vc = segue.destinationViewController as! AddCommentViewController
            vc.photo = photo
            
        default:
            break
        }
    }
}

