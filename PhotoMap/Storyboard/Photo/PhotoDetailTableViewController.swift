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
        
    
    
    
    var rx_sections: Observable<[SectionModel<String, CellStyle>]> {
        
        let rx_photoSection = Observable.just(SectionModel(model: "Photo", items: [CellStyle.photo(photo)]))
        
        let rx_userSection = photo.rx_user
            .map { userInfo in SectionModel(model: "UserInfo", items: [CellStyle.userInfo(userInfo!)] ) }

        let rx_commentsSection = photo.recentComments
            .map { comments in SectionModel(model: "Comments", items: comments.map { CellStyle.comment($0) } ) }
        
        return Observable.combineLatest(rx_photoSection, rx_userSection, rx_commentsSection) { [$0, $1, $2] }

    }
    
    
    private func setupRx() {
        
        title = "加载中..."
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        
        configureDataSource()
        
        sections
            .asDriver()
            .drive(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        
        photo.rx_user
            .subscribeNext { [unowned self] in
                self.sections.value[1].items = $0.recentComments.map { CellStyle.comment($0) }
            }
            .addDisposableTo(disposeBag)

//        rx_sections
//            .doOnError { [unowned self] error in self.title = "评论获取失败"; print(error) }
//            .doOnCompleted { [unowned self] in self.title = "评论获取成功" }
//            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
//            .addDisposableTo(disposeBag)

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
            vc.rx_comment.driveNext(<#T##onNext: Link -> Void##Link -> Void#>)
                .addDisposableTo(disposeBag)

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


