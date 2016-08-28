//
//  NSOperation+Completion.swift
//  playground
//
//  Created by michiru on 2016/08/28.
//  Copyright © 2016年 michiru. All rights reserved.
//

import Foundation

private var associateKVOKey = "operation.extsync.kvo"
private var associateSemaphoreKey = "operation.extsync.semaphore"

extension NSOperation {
    
    func waitUntilDone() {
        if let semaphore = objc_getAssociatedObject(self, &associateSemaphoreKey) as? dispatch_semaphore_t {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
    
    func doneBlock(done: ((Void) -> Void) = {}) {
        
        let semaphore = dispatch_semaphore_create(0)
        
        let kvo = self.addKeyValueObserver("isFinished", options: [.New, .Old], observeChange: { (source, keyPath, change) in
            if change["old"]?.boolValue == false && change["new"]?.boolValue == true { // execute
                done()
                dispatch_semaphore_signal(semaphore)
            }
        })
        
        objc_setAssociatedObject(self, &associateSemaphoreKey, semaphore, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &associateKVOKey, kvo, .OBJC_ASSOCIATION_RETAIN)
    }
}