//
//  UIViewController+AppState.swift
//  playground
//
//  Created by michiru on 2016/08/29.
//  Copyright © 2016年 michiru. All rights reserved.
//

import Foundation
import UIKit

private var associateResignActiveTokenKey = "object.extappstate.resignactivetoken"
private var associateBecameActiveTokenKey = "object.extappstate.becameactivetoken"

extension NSObject {
    func startWillResignActiveHandle(handler: ((Void) -> Void) = {}) {
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil, usingBlock: { _ in
            handler()
        })
        
        objc_setAssociatedObject(self, &associateResignActiveTokenKey, newToken, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func endWillResignActiveHandle() {
        if let token = objc_getAssociatedObject(self, &associateResignActiveTokenKey) as? NSObjectProtocol {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
    }
    
    func startDidBecameActiveHandle(handler: ((Void) -> Void) = {}) {
        
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil, usingBlock: { _ in
            handler()
        })
        
        objc_setAssociatedObject(self, &associateBecameActiveTokenKey, newToken, .OBJC_ASSOCIATION_RETAIN)
    }
    
    func endDidBecameActiveHandle() {
        if let token = objc_getAssociatedObject(self, &associateBecameActiveTokenKey) as? NSObjectProtocol {
            NSNotificationCenter.defaultCenter().removeObserver(token)
        }
    }
}
