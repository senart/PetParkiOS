//
//  OperationErrors.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/26/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

/**
    Abstract:
    This file defines the error codes and convenience functions for interacting with Operation-related errors.
*/

import Foundation

let OperationErrorDomain = "OperationErrors"

enum OperationErrorCode: Int {
    case ConditionFailed = 1
    case ExecutionFailed = 2
}

extension NSError {
    convenience init(code: OperationErrorCode, userInfo: [NSObject: AnyObject]? = nil) {
        self.init(domain: OperationErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}