//
//  CoreDataStackManager.swift
//  Virtual Tourist
//
//  Created by nacho on 5/30/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStackManager {
    
    static let instance = CoreDataStackManager()
    
    class func sharedInstance() -> CoreDataStackManager {
        return instance
    }
    
    lazy var dataModel:CoreDataModel = {
        return CoreDataModel(name: "Uerani", bundle:NSBundle.mainBundle(), storeDirectoryURL:documentsDirectoryURL().URLByAppendingPathComponent("uerani-data"))
    }()
    
    lazy var dataStack:CoreDataStack = { [unowned self] in
        return CoreDataStack(model: self.dataModel)
    }()
    
    func saveContext() {
        var error:NSError? = nil
        if self.dataStack.managedObjectContext.hasChanges {
            do {
                try self.dataStack.managedObjectContext.save()
            } catch let error1 as NSError {
                error = error1
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}
