//
//  NSOperation+Operations.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/29/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import Foundation

extension NSOperation {
    /**
    Add a completion block to be executed after the `NSOperation` enters the
    "finished" state.
    */
    func addCompletionBlock(block: Void -> Void) {
        if let existing = completionBlock {
            /*
            If we already have a completion block, we construct a new one by
            chaining them together.
            */
            completionBlock = {
                existing()
                block()
            }
        }
        else {
            completionBlock = block
        }
    }
}