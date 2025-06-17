//
//  AsyncOperation.swift
//  Concurrency
//
//  Created by Sravan Goud on 17/06/25.
//

import Foundation

class AsyncOperation: Operation, @unchecked Sendable {
    
    private let stateQueue = DispatchQueue(label: "stateQueue", attributes: .concurrent)
    
    private var _state = State.ready
    
    public var state: State {
        get {
            stateQueue.sync {
                return _state
            }
        }
        set {
            let oldValue = _state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                _state = newValue
            }
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    override var isFinished: Bool {
        state == .finished
    }
    
    override var isExecuting: Bool {
        state == .executing
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        main()
    }
    
    override func cancel() {
        state = .finished
    }
}

extension AsyncOperation {
    enum State: String {
        case ready
        case executing
        case finished
        
        var keyPath: String {
            return "is\(rawValue.capitalized)"
        }
    }
}

class Operation1: AsyncOperation, @unchecked Sendable {
    override func main() {
        print("Operation 1: \(Thread.isMainThread)")
        let queue = DispatchQueue(label: "Operation 1", attributes: .concurrent)
        queue.async {
            for i in 0...10 {
                print("Operation 1: \(i)")
            }
            self.state = .finished
        }
    }
}

class Operation2: AsyncOperation, @unchecked Sendable {
    override func main() {
        print("Operation 2: \(Thread.isMainThread)")
        let queue = DispatchQueue(label: "Operation 2", attributes: .concurrent)
        queue.async {
            for i in 0...10 {
                print("Operation 2: \(i)")
            }
            self.state = .finished
        }
    }
}
