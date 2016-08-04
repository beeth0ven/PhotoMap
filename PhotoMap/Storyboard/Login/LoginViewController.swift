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
    var completionHandler: ((AnyObject, NSError) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        
        AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile"]);
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)

        
    }
    
    let disposeBag = DisposeBag()
    
    func setupRx() {
        let usernameValid = usernameTextField
            .rx_text
            .map { !$0.isEmpty }
        
        let passwordValid = passwordTextField
            .rx_text
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
    
    @IBAction private func myLogin() {
        handleLogin(signInProvider: LoginProvider.sharedInstance())
    }
    
    private func handleLogin(signInProvider signInProvider: AWSSignInProvider) {
        title = "正在登录 ..."
        
        AWSIdentityManager.defaultIdentityManager().loginWithSignInProvider(signInProvider) { (result, error) in
            switch error {
            case let error? where error.domain != "success":
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
        passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: usernameTextField.text!, password: passwordTextField.text!))
    }
    
    func getPasswordAuthenticationDetails(authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource) {
        print(String(self.dynamicType), #function)

        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompletePasswordAuthenticationStepWithError(error: NSError?) {
        print(String(self.dynamicType), #function)
        switch error {
        case let error?:
            Queue.Main.execute { self.completionHandler?("", error) }
        default:
            Queue.Main.execute { self.completionHandler?("", NSError(domain: "success", code: -1, userInfo: nil)) }
        }

    }
}

extension LoginViewController {
    
    @nonobjc static let navigationController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as! UINavigationController
    
    static var sharedInstance: LoginViewController {
        return navigationController.viewControllers[0] as! LoginViewController
    }
}

