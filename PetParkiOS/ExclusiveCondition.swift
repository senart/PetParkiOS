//
//  ExclusiveCondition.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import Foundation

/// A generic condition for describing kinds of operations that may not execute concurrently.
struct ExclusiveCondition<T>: OperationCondition {
    
    static var name : String {
        return "Exclusive<\(T.self)>"
    }
    
    static var isExclusive: Bool {
        return true
    }
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        completion(.Satisfied)
    }
}

/**
    The purpose of this enum is to simply provide a non-constructible
    type to be used with `ExclusiveCondition<T>`.
*/
enum Alert { }

/// A condition describing that the targeted operation may present an alert.
typealias AlertPresentation = ExclusiveCondition<Alert>