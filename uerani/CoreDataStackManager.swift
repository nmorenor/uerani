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
    
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        return Static.instance
    }
    
    lazy var dataModel:CoreDataModel = {
        return CoreDataModel(name: "Uerani")
    }()
    
    lazy var dataStack:CoreDataStack = {
        return CoreDataStack(model: self.dataModel)
    }()
    
    func saveContext() {
        var error:NSError? = nil
        if self.dataStack.managedObjectContext.hasChanges && !self.dataStack.managedObjectContext.save(&error) {
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}
