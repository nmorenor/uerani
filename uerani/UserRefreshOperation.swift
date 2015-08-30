//
//  UserRefreshOperation.swift
//  uerani
//
//  Created by nacho on 8/29/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

public class UserRefreshOperation : NSOperation {

    private var semaphore = dispatch_semaphore_create(0)
    
    override init() {
        super.init()
        
        //only allow schedule one at a time
        if LocationRequestManager.sharedInstance().userRefreshOperationQueue.operationCount == 0 {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "mergeChanges:", name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
            
            LocationRequestManager.sharedInstance().userRefreshOperationQueue.addOperation(self)
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
    
    override public func main() {
        //TODO
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
    }
}