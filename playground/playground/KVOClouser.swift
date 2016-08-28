//
//  ObserveContext.swift
//  playground
//
//  Created by michiru on 2016/08/28.
//  Copyright © 2016年 michiru. All rights reserved.
//

import Foundation

typealias KVObserver = (source: NSObject, keyPath: String, change: [NSObject : AnyObject]) -> Void
private let defaultKVODispatcher = KVODispatcher()

func bridge<T : AnyObject>(obj : T) -> UnsafeMutablePointer<Void> {
    return UnsafeMutablePointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

func bridge<T : AnyObject>(ptr : UnsafePointer<Void>) -> T {
    return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
    // return unsafeBitCast(ptr, T.self) // ***
}

class ObserveContext {
    private let source: NSObject
    private let keyPath: String
    private let observer: KVObserver
    
    func __conversion() -> UnsafeMutablePointer<ObserveContext> {
        return UnsafeMutablePointer<ObserveContext>(Unmanaged<ObserveContext>.passUnretained(self).toOpaque())
    }
    
    class func fromPointer(pointer: UnsafeMutablePointer<ObserveContext>) -> ObserveContext {
        return Unmanaged<ObserveContext>.fromOpaque(COpaquePointer(pointer)).takeUnretainedValue()
    }
    
    init(source: NSObject, keyPath: String, observer: KVObserver) {
        self.source = source
        self.keyPath = keyPath
        self.observer = observer
    }
    
    func invokeCallback(change: [String : AnyObject]) {
        observer(source: source, keyPath: keyPath, change: change)
    }
    
    deinit {
        let voidPtr = bridge(self)
        source.removeObserver(defaultKVODispatcher, forKeyPath: keyPath, context: voidPtr)
    }
}

class KVODispatcher : NSObject {
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if let change = change {
            ObserveContext.fromPointer(UnsafeMutablePointer<ObserveContext>(context)).invokeCallback(change)
        }
    }
}

extension NSObject {
    func addKeyValueObserver(keyPath: String, options: NSKeyValueObservingOptions, observeChange: KVObserver) -> ObserveContext? {
        let context = ObserveContext(source: self, keyPath: keyPath, observer: observeChange)
        let voidPtr = bridge(context)
        self.addObserver(defaultKVODispatcher, forKeyPath: keyPath, options: options, context: voidPtr)
        return context
    }
}