//
//  LoginProvider.swift
//  PhotoMap
//
//  Created by luojie on 16/8/2.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

final
class LoginProvider: NSObject {
    
    static func sharedInstance() -> LoginProvider {
        return _sharedInstance
    }
    
    static fileprivate let _sharedInstance = LoginProvider()
    
    var pool: AWSCognitoIdentityUserPool!
    
    override init() {
        super.init()
        
        let serviceConfiguration = AWSServiceConfiguration(region: .usEast1, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "79bl6lftqc428qicgk6ks7sce0", clientSecret: "5ruegj6svqd46u9uvhh2evc3ctgsi7l1k54l9jkepf0plunrqmg", poolId: "us-east-1_Za9P8cJXp")
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "UserPool")
        pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        pool.delegate = self
    }
}

extension LoginProvider: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print(String(describing: type(of: self)), #function)
        return loginViewController
    }
    
    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        fatalError("Identity MultiFactor Authentication Not Supportted!")
    }
    
    fileprivate var loginViewController: LoginViewController {
        return LoginViewController.sharedInstance
    }
}

extension LoginProvider: AWSIdentityProvider {
    
    var identityProviderName: String {
        return "cognito-idp.us-east-1.amazonaws.com/\(pool.userPoolConfiguration.poolId)"
    }
    
    func token() -> AWSTask<NSString> {
        print(String(describing: type(of: self)), #function)
        return pool.token() 
    }
}

extension LoginProvider: AWSSignInProvider {
    
    
    var isLoggedIn: Bool {
        @objc(isLoggedIn) get {
            return UserDefaults.standard.loginProviderIsLoggedIn
        }
    }
    
    var imageURL: URL? {
        return UserDefaults.standard.loginProviderImageURL
    }
    
    var userName: String? {
        return UserDefaults.standard.loginProviderUserName
    }
    
    func login(_ completionHandler: @escaping (Any, Error) -> Void) {
        print(String(describing: type(of: self)), #function)
        loginViewController.doLogin()
    }
    
    func logout() {
        print(String(describing: type(of: self)), #function)
        currentUser?.signOut()
        didLogout()
    }
    
    func reloadSession() {
        print(String(describing: type(of: self)), #function)
        currentUser?.getSession().rx.result
            .do(onError: { print($0) })
            .subscribe(onNext: { _ in  AWSIdentityManager.default().didLogin() })
            .addDisposableTo(disposeBag)
    }
    
    func interceptApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any]? = nil) -> Bool {
        print(String(describing: type(of: self)), #function)
        return true
    }
    
    func interceptApplication(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(String(describing: type(of: self)), #function)
        return false
    }
    
    fileprivate var currentUser: AWSCognitoIdentityUser? {
        return pool.currentUser()
    }
    
}

extension LoginProvider {
    
    func didLogin() {
        UserDefaults.standard.loginProviderIsLoggedIn = true
        UserDefaults.standard.loginProviderUserName = currentUser?.username
    }
    
    func didLogout() {
        UserDefaults.standard.loginProviderIsLoggedIn = false
        UserDefaults.standard.loginProviderUserName = nil
    }
}

extension UserDefaults {
    
    var loginProviderIsLoggedIn: Bool {
        get { return bool(forKey: "loginProviderIsLoggedIn") }
        set { set(newValue, forKey: "loginProviderIsLoggedIn") }
    }
    
    var loginProviderUserName: String? {
        get { return value(forKey: "loginProviderUserName") as? String }
        set { setValue(newValue, forKey: "loginProviderUserName") }
    }
    
    var loginProviderImageURL: URL? {
        get { return (value(forKey: "loginProviderImageURL") as? String).flatMap(URL.init) }
        set { setValue(newValue?.path, forKey: "loginProviderImageURL") }
    }
    
    var loginProviderLoginName: String {
        get { return value(forKey: "loginProviderLoginName") as? String ?? "" }
        set { setValue(newValue, forKey: "loginProviderLoginName") }
    }
    
    var loginProviderPassword: String {
        get { return value(forKey: "loginProviderPassword") as? String ?? "" }
        set { setValue(newValue, forKey: "loginProviderPassword") }
    }
}
