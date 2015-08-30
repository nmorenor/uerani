//
//  AbstractCoreDataOperation.swift
//  uerani
//
//  Created by nacho on 8/30/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

public class AbstractCoreDataOperation : NSOperation {
    
    var semaphore = dispatch_semaphore_create(0)
    
    init(operationQueue:NSOperationQueue?) {
        super.init()
        
        if let operationQueue = operationQueue {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "mergeChanges:", name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
            
            operationQueue.addOperation(self)
        }
        
    }
    
    lazy var sharedModelContext:NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().dataStack.childManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        }()
    
    func mergeChanges(notification:NSNotification) {
        var mainContext:NSManagedObjectContext = CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
        dispatch_async(dispatch_get_main_queue()) {
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
            saveContext(CoreDataStackManager.sharedInstance().dataStack.managedObjectContext) { success, error in
                
                self.unlock()
            }
        }
    }
    
    func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
    }
}
