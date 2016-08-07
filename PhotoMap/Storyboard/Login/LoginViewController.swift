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
        
        usernameTextField.text = pool.getUser().username
        
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
            print("loginWithSignInProvider")
            print("task.result:", result)
            print("task.error:", error)
            print("loggedIn:", LoginProvider.sharedInstance().loggedIn)
            print("identityId:", AWSIdentityManager.defaultIdentityManager().identityId)

            switch error {
            case let error? where error.domain != "success":
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
        //        passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: usernameTextField.text!, password: passwordTextField.text!))
        
        pool.getUser(usernameTextField.text!).getSession(usernameTextField.text!, password: passwordTextField.text!, validationData: nil).continueWithBlock { task -> AnyObject? in
            print("pool.getUser().getSession")
            print("task.result:", task.result)
            print("task.error:", task.error)
            
            if let session = task.result as? AWSCognitoIdentityUserSession {
                
                print("session.idToken:", session.idToken?.tokenString)
                print("session.accessToken:", session.accessToken?.tokenString)
                print("session.refreshToken:", session.refreshToken?.tokenString)
                print("session.expirationTime:", session.expirationTime)
                
//                LoginProvider.sharedInstance().credentialsProvider.identityProvider.identityProviderManager?.logins().continueWithBlock { task -> AnyObject? in
//                    print("credentialsProvider.logins()")
//                    print("task.result:", task.result)
//                    print("task.error:", task.error)
////                    self.completionHandler?(task.result ?? "", task.error ?? NSError(domain: "success", code: -1, userInfo: nil))
////                    self.completionHandler = nil
//                    
//                    LoginProvider.sharedInstance().credentialsProvider.getIdentityId().continueWithBlock({ task -> AnyObject? in
//                        print("credentialsProvider.getIdentityId")
//                        print("task.result:", task.result)
//                        print("task.error:", task.error)
//                        let token = session.accessToken!.tokenString
//                        self.completionHandler?([LoginProvider.sharedInstance().identityProviderName: token], NSError(domain: "success", code: -1, userInfo: nil))
//                        self.completionHandler = nil
//                        return nil
//                    })
//
//                    return nil
//                }
                
                
            }
            
            switch (task.result, task.error) {
            case let (_, error?):
                self.completionHandler?("", error)
                self.completionHandler = nil
            case let (result?, _):
                let token = (result as! AWSCognitoIdentityUserSession).accessToken!.tokenString
                self.completionHandler?([LoginProvider.sharedInstance().identityProviderName: token], NSError(domain: "success", code: -1, userInfo: nil))
                self.completionHandler = nil
            default: break
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
        switch error {
        case let error?:
            Queue.Main.execute {
                self.completionHandler?("", error)
                self.completionHandler = nil
            }
        default:
            break
            //
            //            pool.logins().continueWithBlock({ (task) -> AnyObject? in
            //                Queue.Main.execute {
            //                    print("pool.logins().continueWithBlock")
            //                    print("task.result:", task.result)
            //                    print("task.error:", task.error)
            //
            //                    self.completionHandler?(task.result ?? "", task.error ?? NSError(domain: "success", code: -1, userInfo: nil))
            //                    self.completionHandler = nil
            //                }
            //                return nil
            //            })
            //            Queue.Main.execute {
            //                self.completionHandler?("", NSError(domain: "success", code: -1, userInfo: nil))
            //                self.completionHandler = nil
            //            }
        }
        
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

