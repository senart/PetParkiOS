//
//  GroupOperation.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import UIKit


/**
    A subclass of `Operation` that executes zero or more operations as part of its
    own execution. This class of operation is very useful for abstracting several
    smaller operations into a larger operation.

    Additionally, `GroupOperation`s are useful if you establish a chain of dependencies,
    but part of the chain may "loop". For example, if you have an operation that
    requires the user to be authenticated, you may consider putting the "login"
    operation inside a group operation. That way, the "login" operation may produce
    subsequent operations (still within the outer `GroupOperation`) that will all
    be executed before the rest of the operations in the initial chain of operations.
*/
class GroupOperation: Operation {
    private let internelQueue = OperationQueue()
    private let finishingOperation = NSBlockOperation(block: {})
    
    private var aggregatedErrors = [NSError]()
        
    convenience init(operations: NSOperation...) {
        self.init(operations: operations)
    }
    
    init(operations: [NSOperation]) {
        super.init()
        
        internelQueue.suspended = true
        
        internelQueue.delegate  = self
        
        for operation in operations {
            internelQueue.addOperation(operation)
        }
    }
    
    override func cancel() {
        internelQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func execute() {
        internelQueue.suspended = false
        internelQueue.addOperation(finishingOperation)
    }
    
    func addOperation(operation: NSOperation) {
        internelQueue.addOperation(operation)
    }
    func addOperations(operations: NSOperation...) {
        for operation in operations {
            internelQueue.addOperation(operation)
        }
    }
    
    /**
        Note that some part of execution has produced an error.
        Errors aggregated through this method will be included in the final array
        of errors reported to observers and to the `finished(_:)` method.
    */
    final func aggregateError(error: NSError) {
        aggregatedErrors.append(error)
    }
    
    func operationDidFinish(operation: NSOperation, withErrors errors: [NSError]) {

    }
}

// MARK: OperationQueueDelegate

extension GroupOperation: OperationQueueDelegate {
    final func operationQueue(operationQueue: OperationQueue, willAddOperation operation: NSOperation) {
        assert(!finishingOperation.finished && !finishingOperation.executing, "cannot add new operations to a group after the group has completed")
        
        /*
            Some operation in this group has produced a new operation to execute.
            We want to allow that operation to execute before the group completes,
            so we'll make the finishing operation dependent on this newly-produced operation.
        */
        if operation !== finishingOperation {
            finishingOperation.addDependency(operation)
        }
    }
    
    final func operationQueue(operationQueue: OperationQueue, operationDidFinish operation: NSOperation, withErrors errors: [NSError]) {
        aggregatedErrors.appendContentsOf(errors)
        
        if operation === finishingOperation {
            internelQueue.suspended = true
            finish(aggregatedErrors)
        }
        else {
            operationDidFinish(operation, withErrors: errors)
        }
    }
}
