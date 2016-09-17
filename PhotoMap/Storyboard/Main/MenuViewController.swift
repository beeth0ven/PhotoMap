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
    
    @IBOutlet weak fileprivate var userImageView: UIImageView!
    @IBOutlet weak fileprivate var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUserInfoViews()
        
        print(String(describing: type(of: self)), #function)
        print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
        print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
        print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().isLoggedIn)
        print("AWSIdentityManager.loggedIn:", AWSIdentityManager.default().isLoggedIn)
        print("identityId:", AWSIdentityManager.default().identityId)
        print("userName:", AWSIdentityManager.default().userName)
        print("imageURL:", AWSIdentityManager.default().imageURL)
        
        if !identityManager.isLoggedIn {
            if LoginProvider.sharedInstance().isLoggedIn {
                LoginViewController.sharedInstance.myLogin()
            } else {
                Queue.main.execute { self.present(LoginViewController.navigationController, animated: true, completion: nil) }
            }
        }
        
        observe(for: .AWSIdentityManagerDidSignIn)
            .subscribe(onNext: { [unowned self] _ in self.updateUserInfoViews() })
            .addDisposableTo(disposeBag)
        
        observe(for: .AWSIdentityManagerDidSignOut)
            .subscribe(onNext: { [unowned self] _ in
                self.updateUserInfoViews()
                self.present(LoginViewController.navigationController, animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func updateUserInfoViews() {
        userImageView.rx_setImage(url: identityManager.imageURL)
        usernameLabel.text = identityManager.userName ?? "Guest"
    }
    
    fileprivate var identityManager: AWSIdentityManager {
        return AWSIdentityManager.default()
    }
    
    @IBAction func logout(_ sender: UIButton) {
        
        if identityManager.isLoggedIn  {
            print(String(describing: type(of: self)), #function)
            print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
            print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
            print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().isLoggedIn)
            print("AWSIdentityManager.loggedIn:", AWSIdentityManager.default().isLoggedIn)
            print("identityId:", AWSIdentityManager.default().identityId)
            print("userName:", AWSIdentityManager.default().userName)
            print("imageURL:", AWSIdentityManager.default().imageURL)
            identityManager.logout()
        }
    }
    
    @IBAction func showViewController(_ sender: UIButton) {
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
