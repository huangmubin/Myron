//
//  Notify.swift
//  SwiftiOS
//
//  Created by 黄穆斌 on 16/8/13.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import UIKit

class Notify {
    
    // 通知返回的队列
    static var queue: dispatch_queue_t = dispatch_get_main_queue()
    
    // MARK: - 通用方法
    
    class func post(name: String, info: [NSObject: AnyObject]? = nil) {
        dispatch_async(queue) { 
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil, userInfo: info)
        }
    }
    
    class func add(observer: AnyObject, selector: Selector, name: String, object: AnyObject? = nil) {
        dispatch_async(queue) {
            NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: object)
        }
    }
    
    class func remove(observer: NSObject, name: String? = nil, object: AnyObject? = nil) {
        dispatch_async(queue) {
            if let name = name {
                NSNotificationCenter.defaultCenter().removeObserver(observer, name: name, object: object)
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }
    }
    
    class func info(data: NSNotification, key: NSObject = "info") -> AnyObject? {
        return data.userInfo?[key]
    }
    
    // MARK: - 固定方法
    
    class func addKeyBoardWillShowNotification(observer: AnyObject, selector: Selector, object: AnyObject? = nil) {
        dispatch_async(queue) { 
            NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: UIKeyboardWillShowNotification, object: object)
        }
    }
    
    class func addKeyboardWillChangeFrameNotification(observer: AnyObject, selector: Selector, object: AnyObject? = nil) {
        dispatch_async(queue) {
            NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: UIKeyboardWillChangeFrameNotification, object: object)
        }
    }
    
    class func addKeyboardWillHideNotification(observer: AnyObject, selector: Selector, object: AnyObject? = nil) {
        dispatch_async(queue) {
            NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: UIKeyboardWillHideNotification, object: object)
        }
    }
    
}
