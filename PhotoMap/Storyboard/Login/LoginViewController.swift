//
//  LoginViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/7/31.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

final
class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
        
        usernameTextField.text = NSUserDefaults.standardUserDefaults().loginProviderLoginName
        passwordTextField.text = NSUserDefaults.standardUserDefaults().loginProviderPassword
        
    }
        
    func setupRx() {
        
        let usernameValid = usernameTextField
            .rx_text
            .doOnNext { NSUserDefaults.standardUserDefaults().loginProviderLoginName = $0 }
            .map { !$0.isEmpty }
        
        
        let passwordValid = passwordTextField
            .rx_text
            .doOnNext { NSUserDefaults.standardUserDefaults().loginProviderPassword = $0 }
            .map { $0.characters.count > 7 }
        
        Observable
            .combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .bindTo(loginButton.rx_enabled)
            .addDisposableTo(disposeBag)
        
    }
    
    
    @IBAction private func facebookLogin() {
        handleLogin(signInProvider: AWSFacebookSignInProvider.sharedInstance())
    }
    
    @IBAction private func googleLogin() {
        handleLogin(signInProvider: AWSGoogleSignInProvider.sharedInstance())
    }
    
    @IBAction func myLogin() {
        handleLogin(signInProvider: LoginProvider.sharedInstance())
    }
    
    private func handleLogin(signInProvider signInProvider: AWSSignInProvider) {
//        print(String(self.dynamicType), #function)
        title = "正在登录 ..."
        
        AWSIdentityManager.defaultIdentityManager().loginWithSignInProvider(signInProvider) { (result, error) in
            print(String(self.dynamicType), #function)
            print("task.result:", result)
            print("task.error:", error)
            print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
            print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
            print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().loggedIn)
            print("AWSIdentityManager.loggedIn:", AWSIdentityManager.defaultIdentityManager().loggedIn)
            print("identityId:", AWSIdentityManager.defaultIdentityManager().identityId)
            print("userName:", AWSIdentityManager.defaultIdentityManager().userName)
            print("imageURL:", AWSIdentityManager.defaultIdentityManager().imageURL)

            switch error {
            case let error?:
                print("Login failed.")
                Queue.Main.execute { self.title = "\(signInProvider.identityProviderName)登录失败" }
                print("登录失败:", error.localizedDescription)
            default:
                Queue.Main.execute { self.title = "\(signInProvider.identityProviderName)登录成功" }
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func doLogin() {
        print(String(self.dynamicType), #function)
        
        let username = NSUserDefaults.standardUserDefaults().loginProviderLoginName
        let password = NSUserDefaults.standardUserDefaults().loginProviderPassword
        
        pool.getUser(username).getSession(username, password: password, validationData: nil).continueWithBlock { task -> AnyObject? in
            
            if task.result != nil {
                LoginProvider.sharedInstance().didLogin()
                AWSIdentityManager.defaultIdentityManager().didLogin()
            }
            return nil
        }
        
    }
    
    func getPasswordAuthenticationDetails(authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource) {
        print(String(self.dynamicType), #function)
        
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompletePasswordAuthenticationStepWithError(error: NSError?) {
        print(String(self.dynamicType), #function, error)
//        switch error {
//        case let error?:
//            Queue.Main.execute {
//                self.completionHandler?("", error)
//                self.completionHandler = nil
//            }
//        default:
//            break
//        }
        
    }
    
    private var pool: AWSCognitoIdentityUserPool! {
        return LoginProvider.sharedInstance().pool
    }
}

extension LoginViewController {
    
    @nonobjc static let navigationController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! UINavigationController
    
    static var sharedInstance: LoginViewController {
        return navigationController.viewControllers[0] as! LoginViewController
    }
}

extension AWSIdentityManager {
    func didLogin() {
        performSelector("completeLogin")
    }
}