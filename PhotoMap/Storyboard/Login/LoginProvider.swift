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
    
    lazy var pool: AWSCognitoIdentityUserPool = {
        let serviceConfiguration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: "79bl6lftqc428qicgk6ks7sce0", clientSecret: "5ruegj6svqd46u9uvhh2evc3ctgsi7l1k54l9jkepf0plunrqmg", poolId: "us-east-1_Za9P8cJXp")
        AWSCognitoIdentityUserPool.registerCognitoIdentityUserPoolWithConfiguration(serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "UserPool")
        let result = AWSCognitoIdentityUserPool(forKey: "UserPool")
        //        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "us-east-1:3979f71a-86df-4e9b-becb-6f8173abb69b", identityProviderManager:pool)
        result.delegate = self
        return result
    }()
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
        print(String(self.dynamicType), #function, pool.identityProviderName)
        return pool.identityProviderName
    }
    
    func token() -> AWSTask {
        print(String(self.dynamicType), #function)
        return pool.token()
    }
}

extension LoginProvider: AWSSignInProvider {
    
    var loggedIn: Bool {
        @objc(isLoggedIn) get {
            print(String(self.dynamicType), #function, currentUser?.signedIn)
            return currentUser?.signedIn ?? false
        }
    }
    
    var imageURL: NSURL? {
        return nil
    }
    
    var userName: String? {
        return currentUser?.username
    }
    
    func login(completionHandler: (AnyObject, NSError) -> Void) {
        print(String(self.dynamicType), #function)
        loginViewController.completionHandler = completionHandler
        loginViewController.doLogin()
    }
    
    func logout() {
        print(String(self.dynamicType), #function)
        currentUser?.signOut()
    }
    
    func reloadSession() {
        print(String(self.dynamicType), #function)
        currentUser?.getSession()
    }
    
    func interceptApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }
    
    func interceptApplication(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return false
    }
    
    private var currentUser: AWSCognitoIdentityUser? {
        return pool.currentUser()
    }
    
}