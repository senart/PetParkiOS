//
//  OperationQueue.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import UIKit

/**
    The delegate of an `OperationQueue` can respond to `Operation` lifecycle
    events by implementing these methods.

    In general, implementing `OperationQueueDelegate` is not necessary; you would
    want to use an `OperationObserver` instead. However, there are a couple of
    situations where using `OperationQueueDelegate` can lead to simpler code.
    For example, `GroupOperation` is the delegate of its own internal
    `OperationQueue` and uses it to manage dependencies.
*/
@objc protocol OperationQueueDelegate: NSObjectProtocol {
    optional func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation)
    optional func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError])
}


/**
    `OperationQueue` is an `NSOperationQueue` subclass that implements a large
    number of "extra features" related to the `Operation` class:

    - Notifying a delegate of all operation completion
    - Extracting generated dependencies from operation conditions
    - Setting up dependencies to enforce mutual exclusivity
*/
class OperationQueue: NSOperationQueue {
    
    weak var delegate: OperationQueueDelegate?
    
    override func addOperation(op: NSOperation) {
        if let operation = op as? Operation {
            
            // Set up a `BlockObserver` to invoke the `OperationQueueDelegate` method.
            let delegate = BlockObserver(
                startHandler: nil,
                produceHandler: { [weak self] in
                    self?.addOperation($1)
                },
                finishHandler: { [weak self] in
                    if let q = self {
                        q.delegate?.operationQueue?(q, operationDidFinish: $0, withErrors: $1)
                    }
                }
            )
            
            operation.addObserver(delegate)
            
            // Extract any dependencies needed by this operation.
            var dependencies: [NSOperation] = []
            for condition in operation.conditions {
                if let dependency = condition.dependencyForOperation(operation) {
                    dependencies.append(dependency)
                }
            }
            
            for dependency in dependencies {
                operation.addDependency(dependency)
                
                self.addOperation(dependency)
            }
            
            /*
                With condition dependencies added, we can now see if this needs
                dependencies to enforce mutual exclusivity.
            */
            let exclusivityCategories: [String] = operation.conditions.flatMap { condition in
                if !condition.dynamicType.isExclusive { return nil }
                
                return "\(condition.dynamicType)"
            }
            
            if !exclusivityCategories.isEmpty {
                // Set up the mutual exclusivity dependencies.
                let exclusivityController = ExclusivityController.sharedInstance
                
                exclusivityController.addOperation(operation, categories: exclusivityCategories)
            }
            
            /*
                Indicate to the operation that we've finished our extra work on it
                and it's now it a state where it can proceed with evaluating conditions,
                if appropriate.
            */
            operation.willEnqueue()
        }
        else {
            /*
                For regular `NSOperation`s, we'll manually call out to the queue's
                delegate we don't want to just capture "operation" because that
                would lead to the operation strongly referencing itself and that's
                the pure definition of a memory leak.
            */
            op.addCompletionBlock { [weak self, weak op] in
                if let queue = self,
                    let operation = op {
                        queue.delegate?.operationQueue?(queue, operationDidFinish: operation, withErrors: [])
                }
                else {
                    return
                }
            }
        }
        
        delegate?.operationQueue?(self, willAddOperation: op)
        super.addOperation(op)
    }
    
    
    override func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool) {
        /*
            The base implementation of this method does not call `addOperation()`,
            so we'll call it ourselves.
        */
        for operation in ops {
            addOperation(operation)
        }
        
        if wait {
            for operation in operations {
                operation.waitUntilFinished()
            }
        }
    }
}















