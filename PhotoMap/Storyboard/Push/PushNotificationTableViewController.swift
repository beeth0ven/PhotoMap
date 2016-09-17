//
//  PushNotificationTableViewController.swift
//  PhotoMap
//
//  Created by luojie on 16/8/3.
//  Copyright © 2016年 LuoJie. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AWSMobileHubHelper

class PushNotificationTableViewController: UITableViewController, HasMenuDetailController, DetailChildViewControllerType {
    
    @IBOutlet weak var toggleMenuBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pushManager = AWSPushManager.default()
        
        pushManager.delegate = self
        pushManager.registerForPushNotifications()
        if let topicARNs = pushManager.topicARNs {
            pushManager.registerTopicARNs(topicARNs)
        }
        
        UserInfo.currentUserInfo
            .map { $0?.snsTopicArn }
            .subscribe(onNext: { userARN in
                let topicARNs = pushManager.topicARNs ?? [], userARNs = [userARN].flatMap { $0 }
                print(topicARNs + userARNs)
                pushManager.registerTopicARNs(topicARNs + userARNs)
        })
        .addDisposableTo(disposeBag)
        
        rx_bindToggleShowMenu()
        setupRx()
    }
    
    func setupRx() {
        
        title = "加载中..."
        
        tableView?.dataSource = nil
        tableView?.delegate = nil
        tableView?.rx.setDelegate(self).addDisposableTo(disposeBag)
            
        
        Link.rx_getFormCurrentUser()
            .do(onError: { [unowned self] error in self.title = "用户信息获取失败"; print(error) })
            .do(onCompleted: { [unowned self] in self.title = "用户信息获取成功" })
            .bindTo(tableView!.rx.items(cellIdentifier: "UITableViewCell")) { index, link, cell in
                cell.textLabel?.text = link.kind.description
                cell.detailTextLabel?.text = link.creationDate.flatMap(DateFormatter.string)
            }.addDisposableTo(disposeBag)
    }
}


extension PushNotificationTableViewController: AWSPushManagerDelegate {
    
    func pushManagerDidRegister(_ pushManager: AWSPushManager) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "推送通知注册成功" }
        pushManager.topics.forEach { topic in
            print(topic.topicARN)
            topic.subscribe()
        }
    }
    
    func pushManager(_ pushManager: AWSPushManager, didFailToRegisterWithError error: Error) {
        print(String(describing: type(of: self)), #function, error)
//        Queue.Main.execute { self.title = "推送通知注册失败" }
    }
    
    func pushManager(_ pushManager: AWSPushManager, didReceivePushNotification userInfo: [AnyHashable: Any]) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "成功接收推送通知" }
    }
    
    func pushManagerDidDisable(_ pushManager: AWSPushManager) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "推送通知注销成功" }
    }
    
    func pushManager(_ pushManager: AWSPushManager, didFailToDisableWithError error: Error) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "推送通知注销失败" }
    }
}

extension PushNotificationTableViewController: AWSPushTopicDelegate {
    
    func topicDidSubscribe(_ topic: AWSPushTopic) {
        print(String(describing: type(of: self)), #function, topic.topicARN)
//        print("topicName:", topic.topicName)
//        print("topicARN:", topic.topicARN)
//        print("subscriptionARN:", topic.subscriptionARN)
//        print("endpointARN:", AWSPushManager.defaultPushManager().endpointARN)
//        Queue.Main.execute { self.title = "主题订阅成功" }
    }
    
    func topic(_ topic: AWSPushTopic, didFailToSubscribeWithError error: Error) {
        print(String(describing: type(of: self)), #function, error)
//        Queue.Main.execute { self.title = "主题订阅失败" }
    }
    
    func topicDidUnsubscribe(_ topic: AWSPushTopic) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "主题退订成功" }
    }
    
    func topic(_ topic: AWSPushTopic, didFailToUnsubscribeWithError error: Error) {
        print(String(describing: type(of: self)), #function)
//        Queue.Main.execute { self.title = "主题退订失败" }
    }
}
