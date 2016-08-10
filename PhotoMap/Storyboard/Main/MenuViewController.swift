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
        
        if !identityManager.loggedIn {
            Queue.Main.execute { self.presentViewController(LoginViewController.navigationController, animated: true, completion: nil) }
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
            identityManager.rx_logout()
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
