//
//  NetworkObserver.swift
//  eDynamix
//
//  Created by Stan Mollov on 9/16/15.
//  Copyright © 2015 eDynamix. All rights reserved.
//

import UIKit

struct NetworkObserver: OperationObserver {
    
    init() {}
    
    func operationDidStart(operation: Operation) {
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) { }
    
    func operationDidFinish(operation: Operation, errors: [NSError]) {
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}


