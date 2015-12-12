//
//  BlockObserver.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import Foundation


/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operation`'s lifecycle.
*/
struct BlockObserver: OperationObserver {
    
    private let startHandler: (Operation -> Void)?
    private let produceHandler: ((Operation, NSOperation) -> Void)?
    private let finishHandler: ((Operation, [NSError]) -> Void)?
    
    
    init(startHandler: (Operation -> Void)? = nil, produceHandler: ((Operation, NSOperation) -> Void)? = nil, finishHandler: ((Operation, [NSError]) -> Void)? = nil) {
        self.startHandler   = startHandler
        self.produceHandler = produceHandler
        self.finishHandler  = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: Operation) {
        startHandler?(operation)
    }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(operation: Operation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}