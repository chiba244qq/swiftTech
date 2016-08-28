//
//  NSOperatoin+Timer.swift
//  playground
//
//  Created by michiru on 2016/08/28.
//  Copyright © 2016年 michiru. All rights reserved.
//

import Foundation

// Timer extension
private var associateTimeoutKey = "operation.exttimer.timeout"
private var associateTimerKey = "operation.exttimer.timer"
private var associateKVOKey = "operation.exttimer.kvo"

var token: dispatch_once_t = 0
var runloop: NSRunLoop? = nil

extension NSOperation {
    
    func timerRunLoop() -> NSRunLoop {
        dispatch_once(&token) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                runloop = NSRunLoop.currentRunLoop()
                while(true) {runloop?.runUntilDate(NSDate(timeIntervalSinceNow: 0.5))}
            })
        }
        
        while(runloop == nil) {}
        
        return runloop!
    }
    
    func setTimeout(timeout: NSTimeInterval?, block: ((Void) -> Void) = {}) {
        
        objc_setAssociatedObject(self, &associateTimeoutKey, timeout, .OBJC_ASSOCIATION_RETAIN)
        
        if let timeout = timeout {
            let kvo = self.addKeyValueObserver("isExecuting", options: [.New, .Old], observeChange: { [weak self] (source, keyPath, change) in
                if let sSelf = self {
                    if change["old"]?.boolValue == false && change["new"]?.boolValue == true { // execute
                        sSelf.startTimeoutTimer(timeout, block: block)
                    } else if change["old"]?.boolValue == true && change["new"]?.boolValue == false { // finish
                        sSelf.invalidateTimeoutTimer()
                        objc_setAssociatedObject(sSelf, &associateKVOKey, nil, .OBJC_ASSOCIATION_RETAIN)
                    }
                }
            })
            
            objc_setAssociatedObject(self, &associateKVOKey, kvo, .OBJC_ASSOCIATION_RETAIN)            
        }
    }
    
    private func startTimeoutTimer(timeout: NSTimeInterval, block: ((Void) -> Void)) {
        let timer = NSTimer(timeInterval: timeout, target: NSBlockOperation(block: { [weak self] in
            self?.cancel()
            block()
            }), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
        objc_setAssociatedObject(self, &associateTimerKey, timer, .OBJC_ASSOCIATION_RETAIN)
        
        self.timerRunLoop().addTimer(timer, forMode:NSDefaultRunLoopMode)
    }
    
    private func invalidateTimeoutTimer() {
        if let timer = objc_getAssociatedObject(self, &associateTimerKey) as? NSTimer {
            timer.invalidate()
        }
    }
}