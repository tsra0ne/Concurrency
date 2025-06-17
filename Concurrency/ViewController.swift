//
//  ViewController.swift
//  Concurrency
//
//  Created by Sravan Goud on 16/06/25.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        
//        testConcurrentSync()
//        testConcurrentAsync()
//        creatingDeadlock()
//        testSerialCustomQueue()
//        testConcurrentCustomQueue()
//        testDispatchWorkItem()
//        testDispatchGroupWait()
//        testDispatchGroupNotify()
//        testDispatchBarrier()
//        testBlockOperation()
//        testSyncBlockOperation()
//        testSyncBlockOperationOtherThread()
//        testBlockOperationCompletion()
//        testCustomOperation()
//        testAddOperationQueue()
//        testOperationQueueMaxConcurrent()
//        testOperationQueueDependency()
//        testOperationQueueDG()
        testAsyncOperation()
    }
    
    func testAsyncOperation() {
        let operationQueue = OperationQueue()
        let operation1 = Operation1()
        let operation2 = Operation2()
        let queue = DispatchQueue(label: "underlyingQueue", attributes: .concurrent)
        operation1.completionBlock = { print("Operation 1 completed") }
        operation2.completionBlock = { print("Operation 2 completed") }
        operation1.addDependency(operation2)
//        operationQueue.addOperation(operation1)
//        operationQueue.addOperation(operation2)
//        operationQueue.addOperations([operation1, operation2], waitUntilFinished: false)
        
        // Setting the value of underlyingQueue property when operation count is not equal to 0 (means after we added operation to the operation queue) raises an invalidArgumentException
        operationQueue.underlyingQueue = queue
        operationQueue.addOperations([operation1, operation2], waitUntilFinished: true)
        print("Operations Finished")
        
        // If there is dependency it is smart enough to execute the two operaions on same thread.
        // If you comment out the dependency it will execute on different threads.
    }
    
    func testOperationQueueDG() {
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            for i in 0...4 {
                print("First Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        let operation2 = BlockOperation {
            for i in 0...4 {
                print("Second Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        let operation3 = BlockOperation {
            print("All Blocks Executed")
            print(Thread.isMainThread)
        }
        
        operationQueue.maxConcurrentOperationCount = 3
        operation3.addDependency(operation1)
        operation3.addDependency(operation2)
        operationQueue.addOperations([operation1, operation2, operation3], waitUntilFinished: false)
    }
    
    func testOperationQueueDependency() {
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            for i in 0...4 {
                print("First Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        let operation2 = BlockOperation {
            for i in 0...4 {
                print("Second Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        operationQueue.maxConcurrentOperationCount = 2
        operation1.addDependency(operation2)
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
    }
    
    func testOperationQueueMaxConcurrent() {
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            for i in 0...4 {
                print("First Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        let operation2 = BlockOperation {
            for i in 0...4 {
                print("Second Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
    }
    
    func testAddOperationQueue() {
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            for i in 0...4 {
                print("First Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        let operation2 = BlockOperation {
            for i in 0...4 {
                print("Second Block: \(i)")
                print(Thread.isMainThread)
            }
        }
        
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
    }
    
    func testCustomOperation() {
//        let operation = MyCustomOperation()
//        operation.start()
        
        let operation = MyConcurrentQueue()
        operation.start()
        sleep(1)
        operation.cancel()
    }
    
    func testBlockOperationCompletion() {
        let operation = BlockOperation()
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
        }
        
        operation.completionBlock = {
            print("Completion Block Executed")
        }
        
        DispatchQueue.global(qos: .background).async {
            operation.start()
            print(Thread.isMainThread)
        }
    }
    
    func testSyncBlockOperationOtherThread() {
        let operation = BlockOperation()
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            operation.start()
            print(Thread.isMainThread)
        }
        
        // Blocks the Background Thread as this all tasks are execution Synchronously
        print("All blocks executed")
    }
    
    func testSyncBlockOperation() {
        let operation = BlockOperation()
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        operation.addExecutionBlock {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
        }
        
        operation.start()
        // Blocks the Main Thread as this all tasks are execution Synchronously
        print("All blocks executed")
    }
    
    func testBlockOperation() {
        let operation = BlockOperation {
            for i in 0...10 {
                print("First Block: \(i)")
            }
            print(Thread.isMainThread)
        }
        operation.start()
    }
    
    func testDispatchBarrier() {
        let queue = DispatchQueue(label: "testDispatchBarrier", attributes: .concurrent)
        
        queue.async {
            for i in 0...5 {
                print("First Block: \(i)")
            }
        }
        
        queue.async {
            for i in 0...5 {
                print("Second Block: \(i)")
            }
        }
        
        queue.async(flags: .barrier) {
            for i in 0...5 {
                print("Third Block: \(i)")
            }
        }
        
        queue.async {
            print("#4 task completed")
        }
    }
    
    func testDispatchGroupNotify() {
        let queue = DispatchQueue(label: "testDispatchGroupNotify", attributes: .concurrent)
        let group = DispatchGroup()
        
        queue.async(group: group) {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        // It won't wait for this task
//        queue.async {
//            for i in 0...10 {
//                print("Second Block: \(i)")
//            }
//        }
        
        // It will wait for this task as we added it to group using enter()
        group.enter()
        queue.async {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
            group.leave()
        }
        
        queue.async(group: group) {
            for i in 0...10 {
                print("Third Block: \(i)")
            }
        }
        
        // Will execute completion handler on custom background queue
//        group.notify(queue: queue) {
//            print(Thread.isMainThread)
//            print("Tasks Completed")
//        }
        
        // Will execute completion handler on Main Queue
        group.notify(queue: DispatchQueue.main) {
            print(Thread.isMainThread)
            print("Tasks Completed")
        }
    }
    
    func testDispatchGroupWait() {
        let queue = DispatchQueue(label: "testDispatchGroupWait", attributes: .concurrent)
        let group = DispatchGroup()
        
        group.enter()
        queue.async {
            for i in 0...10 {
                print("First Block: \(i)")
            }
            group.leave()
        }
        
        group.enter()
        queue.async {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
            group.leave()
        }
        
        queue.async {
            group.wait()
            print("Finished")
        }
        
    }
    
    func testDispatchWorkItem() {
        let queue = DispatchQueue(label: "testDispatchWorkItem")
        
        let workItem = DispatchWorkItem {
            print("Block Executed")
        }
        
        queue.async(execute: workItem)
        
        queue.asyncAfter(deadline: .now() + 1, execute: workItem)
        
        workItem.cancel()
        
        queue.async(execute: workItem)
        
        if workItem.isCancelled {
            print("Work Item is cancelled")
        }
    }
    
    func testConcurrentCustomQueue() {
        let concurrentCustomQueue = DispatchQueue(label: "concurrentCustomQueue", attributes: .concurrent)
        
        concurrentCustomQueue.async {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        concurrentCustomQueue.async {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
        }
        
        print("Function Executed")
    }
    
    func testSerialCustomQueue() {
        let serialCustomQueue = DispatchQueue(label: "serialCustomQueue")
        
        serialCustomQueue.async {
            for i in 0...10 {
                print("First Block: \(i)")
            }
        }
        
        serialCustomQueue.async {
            for i in 0...10 {
                print("Second Block: \(i)")
            }
        }
        
        print("Function Executed")
    }
    
    func testConcurrentSync() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.global().sync {
            for i in 0...5000 {
                print("First Block: \(i)")
            }
        }
        
        DispatchQueue.global().sync {
            for i in 0...5000 {
                print("Second Block: \(i)")
            }
        }
        
        print("Main Thread block time: \(CFAbsoluteTimeGetCurrent() - startTime)")
    }
    
    func testConcurrentAsync() {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.global().async {
            for i in 0...5000 {
                print("First Block: \(i)")
            }
        }
        
        DispatchQueue.global().async {
            for i in 0...5000 {
                print("Second Block: \(i)")
            }
        }
        
        print("Main Thread block time: \(CFAbsoluteTimeGetCurrent() - startTime)")
    }
    
    func creatingDeadlock() {
//        DispatchQueue.main.async {
//            DispatchQueue.main.sync {
//                
//            }
//        }
        
        let queue = DispatchQueue(label: "label")
        queue.sync {
            queue.sync {
                
            }
        }
    }

}

class MyCustomOperation: Operation, @unchecked Sendable {
    override func main() {
        for i in 0...10 {
            print("Custom: \(i)")
            print(Thread.isMainThread)
        }
    }
}

class MyConcurrentQueue: Operation, @unchecked Sendable {
    
    override func start() {
        if isExecuting { return }
        // Executes in background thread instead of Main
        Thread.init(block: main).start()
    }
    
    override func main() {
        for i in 0...90000 {
            if isCancelled { return }
            print("Custom: \(i)")
            print(Thread.isMainThread)
        }
    }
}
