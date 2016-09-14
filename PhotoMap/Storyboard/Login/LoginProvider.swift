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
    
    static private let _sharedInstance = LoginProvider()
    
    var pool: AWSCognitoIdentityUserPool!
    
    override init() {
        super.init()
        
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "79bl6lftqc428qicgk6ks7sce0", clientSecret: "5ruegj6svqd46u9uvhh2evc3ctgsi7l1k54l9jkepf0plunrqmg", poolId: "us-east-1_Za9P8cJXp")
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithConfiguration(serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "UserPool")
        pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        pool.delegate = self
    }
}

extension LoginProvider: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        print(String(self.dynamicType), #function)
        return loginViewController
    }
    
    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        fatalError("Identity MultiFactor Authentication Not Supportted!")
    }
    
    private var loginViewController: LoginViewController {
        return LoginViewController.sharedInstance
    }
}

extension LoginProvider: AWSIdentityProvider {
    
    var identityProviderName: String {
        return "cognito-idp.us-east-1.amazonaws.com/\(pool.userPoolConfiguration.poolId)"
    }
    
    func token() -> AWSTask {
        print(String(self.dynamicType), #function)
        return pool.token()
    }
}

extension LoginProvider: AWSSignInProvider {
    
    var loggedIn: Bool {
        @objc(isLoggedIn) get {
            return NSUserDefaults.standardUserDefaults().loginProviderIsLoggedIn
        }
    }
    
    var imageURL: NSURL? {
        return NSUserDefaults.standardUserDefaults().loginProviderImageURL
    }
    
    var userName: String? {
        return NSUserDefaults.standardUserDefaults().loginProviderUserName
    }
    
    func login(completionHandler: (AnyObject, NSError) -> Void) {
        print(String(self.dynamicType), #function)
        loginViewController.doLogin()
    }
    
    func logout() {
        print(String(self.dynamicType), #function)
        currentUser?.signOut()
        didLogout()
    }
    
    func reloadSession() {
        print(String(self.dynamicType), #function)
        currentUser?.getSession().rx_result
            .doOnError { print($0) }
            .subscribeNext { _ in  AWSIdentityManager.defaultIdentityManager().didLogin() }
            .addDisposableTo(disposeBag)
    }
    
    func interceptApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        print(String(self.dynamicType), #function)
        return true
    }
    
    func interceptApplication(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        print(String(self.dynamicType), #function)
        return false
    }
    
    private var currentUser: AWSCognitoIdentityUser? {
        return pool.currentUser()
    }
    
}

extension LoginProvider {
    
    func didLogin() {
        NSUserDefaults.standardUserDefaults().loginProviderIsLoggedIn = true
        NSUserDefaults.standardUserDefaults().loginProviderUserName = currentUser?.username
    }
    
    func didLogout() {
        NSUserDefaults.standardUserDefaults().loginProviderIsLoggedIn = false
        NSUserDefaults.standardUserDefaults().loginProviderUserName = nil
    }
}

extension NSUserDefaults {
    
    var loginProviderIsLoggedIn: Bool {
        get { return boolForKey("loginProviderIsLoggedIn") }
        set { setBool(newValue, forKey: "loginProviderIsLoggedIn") }
    }
    
    var loginProviderUserName: String? {
        get { return valueForKey("loginProviderUserName") as? String }
        set { setValue(newValue, forKey: "loginProviderUserName") }
    }
    
    var loginProviderImageURL: NSURL? {
        get { return (valueForKey("loginProviderImageURL") as? String).flatMap(NSURL.init) }
        set { setValue(newValue?.path, forKey: "loginProviderImageURL") }
    }
    
    var loginProviderLoginName: String {
        get { return valueForKey("loginProviderLoginName") as? String ?? "" }
        set { setValue(newValue, forKey: "loginProviderLoginName") }
    }
    
    var loginProviderPassword: String {
        get { return valueForKey("loginProviderPassword") as? String ?? "" }
        set { setValue(newValue, forKey: "loginProviderPassword") }
    }
}
