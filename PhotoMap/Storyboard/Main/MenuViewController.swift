//
//  MenuViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/9.
//
//

import UIKit
import RxSwift
import RxCocoa
import AWSMobileHubHelper

class MenuViewController: UIViewController, HasMenuDetailController {
    
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserInfoViews()
        
        print(String(self.dynamicType), #function)
        print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
        print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
        print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().loggedIn)
        print("AWSIdentityManager.loggedIn:", AWSIdentityManager.defaultIdentityManager().loggedIn)
        print("identityId:", AWSIdentityManager.defaultIdentityManager().identityId)
        print("userName:", AWSIdentityManager.defaultIdentityManager().userName)
        print("imageURL:", AWSIdentityManager.defaultIdentityManager().imageURL)
        
        if !identityManager.loggedIn {
            if LoginProvider.sharedInstance().loggedIn {
                LoginViewController.sharedInstance.myLogin()
            } else {
                Queue.Main.execute { self.presentViewController(LoginViewController.navigationController, animated: true, completion: nil) }
            }
        }
        
        observe(for: AWSIdentityManagerDidSignInNotification)
            .subscribeNext { [unowned self] _ in self.updateUserInfoViews() }
            .addDisposableTo(disposeBag)
        
        observe(for: AWSIdentityManagerDidSignOutNotification)
            .subscribeNext { [unowned self] _ in
                self.updateUserInfoViews()
                self.presentViewController(LoginViewController.navigationController, animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
    }
    
    private func updateUserInfoViews() {
        userImageView.rx_setImage(url: identityManager.imageURL)
        usernameLabel.text = identityManager.userName ?? "Guest"
    }
    
    private var identityManager: AWSIdentityManager {
        return AWSIdentityManager.defaultIdentityManager()
    }
    
    @IBAction func logout(sender: UIButton) {
        
        if identityManager.loggedIn  {
            print(String(self.dynamicType), #function)
            print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
            print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
            print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().loggedIn)
            print("AWSIdentityManager.loggedIn:", AWSIdentityManager.defaultIdentityManager().loggedIn)
            print("identityId:", AWSIdentityManager.defaultIdentityManager().identityId)
            print("userName:", AWSIdentityManager.defaultIdentityManager().userName)
            print("imageURL:", AWSIdentityManager.defaultIdentityManager().imageURL)
            identityManager.logout()
        }
    }
    
    @IBAction func showViewController(sender: UIButton) {
        menuDetailController!.rx_currentIndex.value = sender.tag
        menuDetailController?.rx_showMenu.value = false
    }
    
}

extension AWSUserDefaults {
    
    var isUserInfoSetted: Bool {
        get { return awsUserDefaults.boolForKey("isUserInfoSetted") }
        set { awsUserDefaults.setBool(newValue, forKey: "isUserInfoSetted") }
    }
}
