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
import RxDataSources

class PhotoDetailTableViewController: UITableViewController {
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, CellStyle>>()
    
    lazy var sections: Variable<[SectionModel<String, CellStyle>]> = {
        
        let sections = [
            SectionModel(model: "Photo", items: [CellStyle.photo(self.photo)]),
            SectionModel(model: "UserInfo", items: []),
            SectionModel(model: "Comments", items: []),
        ]
                
        return  Variable(sections)
        
    }()
    
    var comments: [Link] {
        get {
            return sections.value[2].items.map {
                guard case .comment(let comment) = $0 else { abort() }
                return comment
            }
        }
        set { sections.value[2].items = newValue.map { CellStyle.comment($0) } }
    }
    
    private func setupRx() {
        
//        title = "加载中..."
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        
        configureDataSource()
        
        sections
            .asDriver()
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        photo.rx_user
            .subscribeNext { [unowned self] in
                self.sections.value[1].items = [CellStyle.userInfo($0!)]
            }
            .addDisposableTo(disposeBag)
        
        photo.recentComments
            .subscribeNext { [unowned self] in
                self.comments = $0
            }
            .addDisposableTo(disposeBag)

    }
    
    private func configureDataSource() {
        
        dataSource.configureCell = { dataSource, tableView, indexPath, cellStyle in
            switch cellStyle {
            case .photo(let photo):
                let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
                cell.photo = photo
                return cell

            case .userInfo(let userInfo):
                let cell = tableView.dequeueReusableCellWithIdentifier("UserInfoTableViewCell") as! UserInfoTableViewCell
                cell.userInfo = userInfo
                return cell

            case .comment(let comment):
                let cell = tableView.dequeueReusableCellWithIdentifier("CommentTableViewCell") as! CommentTableViewCell
                cell.comment = comment
                return cell

            }
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionAtIndex(index).model
        }
    }
    
    @IBAction func toggleLikeState(sender: UIButton) {
        
        photo.rx_setLike(!sender.selected)
            .doOnError { [unowned self] error in self.title = "切换喜欢图片失败"; print(error) }
            .subscribeCompleted { [unowned self] in self.title = "切换喜欢图片成功"; sender.selected = !sender.selected }
            .addDisposableTo(disposeBag)
    }
}

extension PhotoDetailTableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "AddComment"?:
            let vc = segue.destinationViewController as! AddCommentViewController
            vc.photo = photo
            vc.rx_comment
                .driveNext { [unowned self] in
                    self.comments.insert($0, atIndex: 0)
                }
                .addDisposableTo(disposeBag)
            
        case "ShowUser"?:
            let vc = segue.destinationViewController as! UserDetailTableViewController
            let cell = sender as! UserInfoTableViewCell, userInfo = cell.userInfo
            vc.rx_userInfo = Observable.just(userInfo).asFlatVariable()
            vc.navigationItem.leftBarButtonItem = nil
            
        default:
            break
        }
    }
}

extension PhotoDetailTableViewController {
    
    enum CellStyle {
        case photo(Photo)
        case userInfo(UserInfo)
        case comment(Link)
    }
}


