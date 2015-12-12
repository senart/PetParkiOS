//
//  ExclusivityController.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import UIKit


/**
    `ExclusivityController` is a singleton to keep track of all the in-flight
    `Operation` instances that have declared themselves as requiring mutual exclusivity.
    We use a singleton because mutual exclusivity must be enforced across the entire
    app, regardless of the `OperationQueue` on which an `Operation` was executed.
*/
class ExclusivityController {
    static let sharedInstance = ExclusivityController()
    
    private let serialQueue = dispatch_queue_create("Operations.ExclusivityController", DISPATCH_QUEUE_SERIAL)
    private var operations: [String: [Operation]] = [:]
    
    private init() {
        /*
            A private initializer effectively prevents any other part of the app
            from accidentally creating an instance.
        */
    }
    
    /// Registers an operation as being exclusive
    func addOperation(operation: Operation, categories: [String]) {
        /*
            This needs to be a synchronous operation.
            If this were async, then we might not get around to adding dependencies
            until after the operation had already begun, which would be incorrect.
        */
        dispatch_sync(serialQueue) {
            for category in categories {
                self.addOperationInCategory(operation, category: category)
            }
        }
        
    }
    
    /// Unregisters an operation from being exclusive
    func removeOperation(operation: Operation, categories: [String]) {
        
        dispatch_async(serialQueue) {
            for category in categories {
                self.removeOperationInCategory(operation, category: category)
            }
        }
        
    }
    
    
    // MARK: Operation Management
    
    private func addOperationInCategory(operation: Operation, category: String) {
        
        var operationsForThisCategory = operations[category] ?? []
        
        if let last = operationsForThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsForThisCategory.append(operation)
        
        operations[category] = operationsForThisCategory
        
    }
    
    private func removeOperationInCategory(operation: Operation, category: String) {
        let matchingOperations = operations[category]
        
        if var operationsForThisCategory = matchingOperations {
            
            let index = operationsForThisCategory.indexOf(operation)
            
            operationsForThisCategory.removeAtIndex(index!)
            operations[category] = operationsForThisCategory
        }
        
    }
}