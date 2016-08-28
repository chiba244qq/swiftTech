//
//  ViewController.swift
//  playground
//
//  Created by michiru on 2016/08/28.
//  Copyright © 2016年 michiru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private let queue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let block = NSBlockOperation {
            print("operating")
            NSThread.sleepForTimeInterval(2.0)
            print("operated")
        }
        
        block.setTimeout(1.0) {
            print("timeout")
        }
        
        block.doneBlock({
            print("done")
        })
        
        block.completionBlock = {
            print("completion")
        }
        
        queue.addOperation(block)
        
        block.waitUntilDone()
        print("doned")
    }
    

}

