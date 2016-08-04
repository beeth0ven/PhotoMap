//
//  MenuTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/3.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AWSMobileHubHelper

class MenuTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !AWSIdentityManager.defaultIdentityManager().loggedIn {
            presentViewController(LoginViewController.navigationController, animated: true, completion: nil)
        }
        
        NSNotificationCenter.defaultCenter().rx_notification(AWSIdentityManagerDidSignInNotification)
            .subscribeNext { _ in print("接到登录成功通知！") }
            .addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter().rx_notification(AWSIdentityManagerDidSignOutNotification)
            .subscribeNext { _ in print("接到登出成功通知！") }
            .addDisposableTo(disposeBag)
        
//        LoginProvider.sharedInstance().logout()
        
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        
        if AWSIdentityManager.defaultIdentityManager().loggedIn  {
            print("identityId:", AWSIdentityManager.defaultIdentityManager().identityId)
            print("userName:", AWSIdentityManager.defaultIdentityManager().userName)
            print("imageURL:", AWSIdentityManager.defaultIdentityManager().imageURL)
            AWSIdentityManager.defaultIdentityManager().logoutWithCompletionHandler { (_, error) in
                Queue.Main.execute {  self.presentViewController(LoginViewController.navigationController, animated: true, completion: nil) }

            }
        }
       
    }
}