//
//  UserDetailTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/29.
//
//

import UIKit
import AWSDynamoDB
import AWSMobileHubHelper
import RxSwift
import RxCocoa

class UserDetailTableViewController: UITableViewController, HasMenuDetailController, DetailChildViewControllerType {
    
    var rx_userInfo: FlatVariable<UserInfo>! = UserInfo.currentUserInfo
        .filter { $0 != nil }
        .map { $0! }
        .asFlatVariable()
    
    @IBOutlet var toggleMenuBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var followBarButtonItem: UIBarButtonItem!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var usernameLable: UILabel!
    
    @IBOutlet private weak var postedCountLabel: UILabel!
    @IBOutlet private weak var likedCountLabel: UILabel!
    
    @IBOutlet private weak var followingCountLabel: UILabel!
    @IBOutlet private weak var followerCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    private func setupRx() {
        
        rx_bindToggleShowMenu()
        
        rx_userInfo.asObservable()
            .subscribeNext { [unowned self] in self.updateUI(with: $0) }
            .addDisposableTo(disposeBag)
        
        followBarButtonItem.rx_tap
            .debug()
            .flatMapLatest { [unowned self] () -> Observable<Link> in
                let followed = self.followBarButtonItem.title == "Followed"
                return self.rx_userInfo.value.rx_followUser(!followed)
            }
            .doOnError { [unowned self] error in self.title = "切换关注状态失败"; print(error) }
            .subscribeNext { [unowned self] _ in self.title = "切换关注状态成功";
                self.followBarButtonItem.title = (self.followBarButtonItem.title == "Followed") ? "Follow" : "Followed"
            }
            .addDisposableTo(disposeBag)

    }
    
    private func updateUI(with model: UserInfo) {
        
        imageView.rx_setImage(url: model.imageURL)
        usernameLable.text = model.displayName ?? "Guest"
        
        if model.isMe {
            followBarButtonItem.enabled = false
        } else {
            model.rx_followedByCurrentUserLink
                .doOnError {  error in print(error) }
                .subscribeNext { [unowned self] link in
                    self.followBarButtonItem.enabled = true
                    self.followBarButtonItem.title = (link != nil) ? "Followed" : "Follow"
                }
                .addDisposableTo(disposeBag)
        }
        
        model.rx_postedCount.driveNext { [unowned self] count in
            self.postedCountLabel.text = "\(count)"
            }
            .addDisposableTo(disposeBag)
        
        model.rx_likedCount.driveNext { [unowned self] count in
            self.likedCountLabel.text = "\(count)"
            }
            .addDisposableTo(disposeBag)
        
        model.rx_followingCount.driveNext { [unowned self] count in
            self.followingCountLabel.text = "\(count)"
            }
            .addDisposableTo(disposeBag)
        
        model.rx_followerCount.driveNext { [unowned self] count in
            self.followerCountLabel.text = "\(count)"
            }
            .addDisposableTo(disposeBag)
        
    }
    
}

extension UserDetailTableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "ShowPosted"?:
            let vc = segue.destinationViewController as! PhotosCollectionViewController
            vc.rx_getData = rx_userInfo.asObservable()
                .flatMapLatest { $0.rx_postedPhotos }
            vc.navigationItem.leftBarButtonItem = nil
            
        case "ShowLiked"?:
            let vc = segue.destinationViewController as! PhotosCollectionViewController
            vc.rx_getData = rx_userInfo.asObservable()
                .flatMapLatest { $0.rx_likedPhotos }
            vc.navigationItem.leftBarButtonItem = nil
            
        case "ShowFollowing"?:
            let vc = segue.destinationViewController as! UsersTableViewController
            vc.rx_getData = rx_userInfo.asObservable()
                .flatMapLatest { $0.rx_followingUsers }
            
        case "ShowFollower"?:
            let vc = segue.destinationViewController as! UsersTableViewController
            vc.rx_getData = rx_userInfo.asObservable()
                .flatMapLatest { $0.rx_followerUsers }
        
        default:
            break
        }
    }
}
