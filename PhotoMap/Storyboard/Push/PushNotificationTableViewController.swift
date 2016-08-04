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

class PushNotificationTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pushManager = AWSPushManager.defaultPushManager()
        
        pushManager.delegate = self
        pushManager.registerForPushNotifications()
        if let topicARNs = pushManager.topicARNs {
            pushManager.registerTopicARNs(topicARNs)
        }
    }
}


extension PushNotificationTableViewController: AWSPushManagerDelegate {
    
    func pushManagerDidRegister(pushManager: AWSPushManager) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "推送通知注册成功" }
        if let arn = pushManager.topicARNs?.first {
            let topic = pushManager.topicForTopicARN(arn)
            topic.subscribe()
        }
    }
    
    func pushManager(pushManager: AWSPushManager, didFailToRegisterWithError error: NSError) {
        print(String(self.dynamicType), #function, error)
        Queue.Main.execute { self.title = "推送通知注册失败" }
    }
    
    func pushManager(pushManager: AWSPushManager, didReceivePushNotification userInfo: [NSObject : AnyObject]) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "成功接收推送通知" }
    }
    
    func pushManagerDidDisable(pushManager: AWSPushManager) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "推送通知注销成功" }
    }
    
    func pushManager(pushManager: AWSPushManager, didFailToDisableWithError error: NSError) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "推送通知注销失败" }
    }
}

extension PushNotificationTableViewController: AWSPushTopicDelegate {
    
    func topicDidSubscribe(topic: AWSPushTopic) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "主题订阅成功" }
    }
    
    func topic(topic: AWSPushTopic, didFailToSubscribeWithError error: NSError) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "主题订阅失败" }
    }
    
    func topicDidUnsubscribe(topic: AWSPushTopic) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "主题退订成功" }
    }
    
    func topic(topic: AWSPushTopic, didFailToUnsubscribeWithError error: NSError) {
        print(String(self.dynamicType), #function)
        Queue.Main.execute { self.title = "主题退订失败" }
    }
}