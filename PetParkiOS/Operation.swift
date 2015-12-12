//
//  Operation.swift
//  eDynamix
//
//  Created by Stan Mollov on 6/26/15.
//  Copyright (c) 2015 eDynamix. All rights reserved.
//

import UIKit


/**
    The subclass of `NSOperation` from which all other operations should be derived.
    This class adds both Conditions and Observers, which allow the operation to define
    extended readiness requirements, as well as notify many interested parties
    about interesting operation state changes
*/
class Operation: NSOperation {
    
    var errorController: UIViewController?
    
    // use the KVO mechanism to indicate that changes to "state" affect other properties as well
    class func keyPathsForValuesAffectingIsReady() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state"]
    }
    
    class func keyPathsForValuesAffectingIsCancelled() -> Set<NSObject> {
        return ["state"]
    }
    
    // MARK: State Management
    
    private enum State: Int, Comparable {
        /// The initial state of an `Operation`.
        case Initialized
        
        /// The `Operation` is ready to begin evaluating conditions.
        case Pending
        
        /// The `Operation` is evaluating conditions.
        case EvaluatingConditions
        
        /**
            The `Operation`'s conditions have all been satisfied, and it is ready
            to execute.
        */
        case Ready
        
        /// The `Operation` is executing.
        case Executing
        
        /// The `Operation` has finished executing.
        case Finished
        
        /// The `Operation` has been cancelled.
        case Cancelled
    }
    
    /**
        Fires by OperatuonQueue and indicate that Operation can now begin evaluate conditions
    */
    func willEnqueue() {
        state = .Pending
    }
    
    /// Private storage for the `state` property that will be KVO observed.
    private var _state = State.Initialized
    
    private var state: State {
        get {
            return _state
        }
        
        
        set(newState) {
            
            // Manually fire the KVO notifications for state change, since this is "private".
            willChangeValueForKey("state")
            
            switch (_state, newState) {
            case (.Cancelled, _):
                break // cannot leave cancelled state
            case (.Finished, _):
                break // canndot leave finished state
            default:
                assert(_state != newState, "Performing invalid cyclic state transition.")
                _state = newState
            }
            
            didChangeValueForKey("state")
        }
        
        
    }
    
    // Here is where we extend our definition of "readiness".
    override var ready: Bool {
        switch state {
        case .Pending:
            if super.ready {
                // start evaluating conditions
                evaluateConditions()
            }
            
            return false
            
        case .Ready:
            return super.ready
            
        default:
            return false
        }
    }
    
    var userInitiated: Bool {
        get {
            return qualityOfService == .UserInitiated
        }
        
        set {
            assert(state < .Executing, "Cannot modify userInitiated after execution has begun.")
            
            qualityOfService = newValue ? .UserInitiated : .Default
        }
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override var cancelled: Bool {
        return state == .Cancelled
    }
    
    
    // MARK: Conditions and Observers
    
    private(set) var conditions = [OperationCondition]()
    
    final func addCondition(condition: OperationCondition) {
        assert(state < .EvaluatingConditions, "Cannot add conditions after evaluation has been started.")
        
        conditions.append(condition)
    }
    
    private func evaluateConditions() {
        assert(state == .Pending, "evaluateConditions() was executed out of order")
        
        state = .EvaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            if failures.isEmpty {
                // If there were no errors, we may proceed.
                self.state = .Ready
                
            } else {
                self.state = .Cancelled
                self.finish(failures)
            }
        }
        
    }
    
    private(set) var observers = [OperationObserver]()
    
    func addObserver(observer: OperationObserver) {
        assert(state < .Executing, "Cannot modify observers after execution has begun")
        
        observers.append(observer)
    }
    
    override func addDependency(op: NSOperation) {
        assert(state <= .Executing, "Dependencies cannot be modified after execution has begun")
        
        super.addDependency(op)
    }
    
    // MARK: Execution Cancellation
    
    final override func start() {
        assert(state == .Ready, "The operation must be ready before start executing")
        
        state = .Executing
        
        for observer in observers {
            observer.operationDidStart(self)
        }
        
        execute()
    }
    
    /**
        `execute()` is the entry point of execution for all `Operation` subclasses.
        If you subclass `Operation` and wish to customize its execution, you would
        do so by overriding the `execute()` method.
        
        At some point, your `Operation` subclass must call one of the "finish"
        methods defined below; this is how you indicate that your operation has
        finished its execution, and that operations dependent on yours can re-evaluate
        their readiness state.
    */
    func execute() {
        print("\(self.dynamicType) must override execute()")
        
        finish()
    }
    
    private var _internalErrors: [NSError] = []
    override func cancel() {
        cancelWithError()
    }
    
    func cancelWithError(error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        state = .Cancelled
    }
    
    final func produceOperation(operation: NSOperation) {
        for observer in observers {
            observer.operation(self, didProduceOperation: operation)
        }
    }
    
    // MARK: Finishing
    
    /**
        Most operations may finish with a single error, if they have one at all.
        This is a convenience method to simplify calling the actual `finish()`
        method. This is also useful if you wish to finish with an error provided
        by the system frameworks. As an example, see `DownloadEarthquakesOperation`
        for how an error from an `NSURLSession` is passed along via the
        `finishWithError()` method.
    */
    final func finishWithError(error: NSError?) {
        if let error = error {
            finish([error])
        } else {
            finish()
        }
    }
    
    private var hasFinishedAlready = false
    final func finish(errors: [NSError] = []) {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            
            let combinedErrors = _internalErrors + errors
            finished(combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(self, errors: combinedErrors)
            }
            
            state = .Finished
        }
    }
    
    /**
        Subclasses may override `finished(_:)` if they wish to react to the operation
        finishing with errors. For example, the `LoadModelOperation` implements
        this method to potentially inform the user about an error when trying to
        bring up the Core Data stack.
    */
    func finished(errors: [NSError]) {
        if let firstError = errors.first {
            let alert = AlertOperation(presentationContext: errorController)
            
            let name = self.name ?? "Group Operation"
            alert.title   = "\(name) Error"
            alert.message = firstError.localizedDescription
            
            produceOperation(alert)
        }
    }
    
    override func waitUntilFinished() {
        /*
        Waiting on operations is almost NEVER the right thing to do. It is
        usually superior to use proper locking constructs, such as `dispatch_semaphore_t`
        or `dispatch_group_notify`, or even `NSLocking` objects. Many developers
        use waiting when they should instead be chaining discrete operations
        together using dependencies.
        
        To reinforce this idea, invoking `waitUntilFinished()` will crash your
        app, as incentive for you to find a more appropriate way to express
        the behavior you're wishing to create.
        */
        fatalError("Waiting on operations is an anti-pattern. Remove this ONLY if you're absolutely sure there is No Other Way™.")
    }
    
}

// Simple operator functions to simplify the assertions used above.
private func ==(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

private func <(lhs: Operation.State, rhs: Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}