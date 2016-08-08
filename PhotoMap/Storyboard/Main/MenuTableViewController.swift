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
            .doOnNext { _ in print("接到登录成功通知！") }
            .flatMapLatest { _ in AWSUserDefaults.sharedInstance.rx_synchronize() }
            .subscribeNext { userDefaults in print("isUserInfoSetted:", userDefaults.isUserInfoSetted) }
            .addDisposableTo(disposeBag)
        
        NSNotificationCenter.defaultCenter().rx_notification(AWSIdentityManagerDidSignOutNotification)
            .subscribeNext { _ in print("接到登出成功通知！") }
            .addDisposableTo(disposeBag)
        
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

extension AWSUserDefaults {
    
    var isUserInfoSetted: Bool {
        get { return awsUserDefaults.boolForKey("isUserInfoSetted") }
        set { awsUserDefaults.setBool(newValue, forKey: "isUserInfoSetted") }
    }
}