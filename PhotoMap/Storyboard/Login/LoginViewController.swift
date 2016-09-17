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
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
        
        usernameTextField.text = UserDefaults.standard.loginProviderLoginName
        passwordTextField.text = UserDefaults.standard.loginProviderPassword
        
    }
        
    func setupRx() {
        
        let usernameValid = usernameTextField
            .rx.textInput.text
            .do(onNext: { UserDefaults.standard.loginProviderLoginName = $0 })
            .map { !$0.isEmpty }
        
        
        let passwordValid = passwordTextField
            .rx.textInput.text
            .do(onNext: { UserDefaults.standard.loginProviderPassword = $0 })
            .map { $0.characters.count > 7 }
        
        Observable
            .combineLatest(usernameValid, passwordValid) { $0 && $1 }
            .bindTo(loginButton.rx.enabled)
            .addDisposableTo(disposeBag)
        
    }
    
    
    @IBAction fileprivate func facebookLogin() {
        handleLogin(signInProvider: AWSFacebookSignInProvider.sharedInstance())
    }
    
    @IBAction fileprivate func googleLogin() {
        handleLogin(signInProvider: AWSGoogleSignInProvider.sharedInstance())
    }
    
    @IBAction func myLogin() {
        handleLogin(signInProvider: LoginProvider.sharedInstance())
    }
    
    fileprivate func handleLogin(signInProvider: AWSSignInProvider) {
//        print(String(self.dynamicType), #function)
        title = "正在登录 ..."
        
        AWSIdentityManager.default().loginWithSign(signInProvider) { (result, error) in
            print(String(describing: type(of: self)), #function)
            print("task.result:", result)
            print("task.error:", error)
            print("currentUser:", LoginProvider.sharedInstance().pool.currentUser())
            print("currentUser.username:", LoginProvider.sharedInstance().pool.currentUser()?.username)
            print("LoginProvider.loggedIn:", LoginProvider.sharedInstance().isLoggedIn)
            print("AWSIdentityManager.loggedIn:", AWSIdentityManager.default().isLoggedIn)
            print("identityId:", AWSIdentityManager.default().identityId)
            print("userName:", AWSIdentityManager.default().userName)
            print("imageURL:", AWSIdentityManager.default().imageURL)

            switch error {
            case let error?:
                print("Login failed.")
                Queue.main.execute { self.title = "\(signInProvider.identityProviderName)登录失败" }
                print("登录失败:", error.localizedDescription)
            default:
                Queue.main.execute { self.title = "\(signInProvider.identityProviderName)登录成功" }
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func doLogin() {
        print(String(describing: type(of: self)), #function)
        
        let username = UserDefaults.standard.loginProviderLoginName
        let password = UserDefaults.standard.loginProviderPassword
        
        pool.getUser(username).getSession(username, password: password, validationData: nil).continue({ task -> Any? in
            
            if task.result != nil {
                LoginProvider.sharedInstance().didLogin()
                AWSIdentityManager.default().didLogin()
            }
            return nil
        })
        
    }
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        print(String(describing: type(of: self)), #function)
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    
    func didCompleteStepWithError(_ error: Error?) {
        print(String(describing: type(of: self)), #function, error)
    }
    fileprivate var pool: AWSCognitoIdentityUserPool! {
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
        perform(Selector("completeLogin"))
    }
}
