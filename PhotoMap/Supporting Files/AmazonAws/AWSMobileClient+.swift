//
//  AWSMobileClient+.swift
//  PhotoMap
//
//  Created by luojie on 16/8/10.
//
//

import Foundation
import UIKit
import AWSCore
import AWSMobileHubHelper
import RxSwift
import RxCocoa

extension AWSMobileClient {
    
    func handleLogin() {
//        print(String(self.dynamicType), #function)
        observe(for: AWSIdentityManagerDidSignInNotification)
            .doOnNext { _ in print("接到登录成功通知！") }
            .flatMapLatest { _ in AWSUserDefaults.sharedInstance.rx_synchronize() }
            .filter { !$0.isUserInfoSetted }
            .flatMapLatest { _ -> Observable<UserInfo> in
                print("正在保存用户信息...")
                return AWSIdentityManager.defaultIdentityManager().rx_saveUserInfo()
            }
            .flatMapLatest { _ -> Observable<AWSUserDefaults> in
                print("正在更新 isUserInfoSetted ...")
                AWSUserDefaults.sharedInstance.isUserInfoSetted = true
                return AWSUserDefaults.sharedInstance.rx_synchronize()
            }
            .subscribeNext { userDefaults in print("isUserInfoSetted:", userDefaults.isUserInfoSetted) }
            .addDisposableTo(disposeBag)
        
        observe(for: AWSIdentityManagerDidSignOutNotification)
            .subscribeNext { _ in print("接到登出成功通知！") }
            .addDisposableTo(disposeBag)
    }
}