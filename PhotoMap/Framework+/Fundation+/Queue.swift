//
//  Queue.swift
//  Education
//
//  Created by luojie on 15/12/15.
//  Copyright © 2015年 牛至网. All rights reserved.
//

import Foundation

/**
 提供常用线程的简单访问方法. 用 Qos 代表线程对应的优先级。
    - Main:                 对应主线程
    - UserInteractive:      对应优先级高的线程
    - UserInitiated:        对应优先级中的线程
    - Utility:              对应优先级低的线程
    - Background:           对应后台的线程
    
    例如，异步下载图片可以这样写：
    ```swift
    Queue.UserInitiated.execute {
 
        let url = NSURL(string: "http://image.jpg")!
        let data = NSData(contentsOfURL: url)!
        let image = UIImage(data: data)
        
        Queue.Main.execute {
            imageView.image = image
        }
    }
 */

public enum Queue: ExcutableQueue {
    case Main
    case UserInteractive
    case UserInitiated
    case Utility
    case Background
    
    public var queue: dispatch_queue_t {
        switch self {
        case .Main:
            return dispatch_get_main_queue()
        case .UserInteractive:
            return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        case .UserInitiated:
            return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        case .Utility:
            return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        case .Background:
            return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        }
    }
}

/// 提供本 App 要使用的所有 SerialQueue，以下的 case 只是一个例子，可以根据需要修改
public enum SerialQueue: String, ExcutableQueue {

    case DownLoadImage = "ovfun.Education.SerialQueue.DownLoadImage"
    case UpLoadFile = "ovfun.Education.SerialQueue.UpLoadFile"

    public var queue: dispatch_queue_t {
        return dispatch_queue_create(rawValue, DISPATCH_QUEUE_SERIAL)
    }
}

/// 给 Queue 提供默认的执行能力
public protocol ExcutableQueue {
   
    var queue: dispatch_queue_t { get }
}

extension ExcutableQueue {
  
    public func execute(closure: () -> Void) {
        dispatch_async(queue, closure)
    }
    
    public func executeAfter(seconds seconds: NSTimeInterval, closure: () -> Void) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        dispatch_after(delay, queue, closure)
    }
}