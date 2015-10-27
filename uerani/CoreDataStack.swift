//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by nacho on 6/8/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

public typealias ChildManagedObjectContext = NSManagedObjectContext

public final class CoreDataStack:CustomStringConvertible {
    
    public let model:CoreDataModel
    public let managedObjectContext:NSManagedObjectContext
    public let persistentStoreCoordinator:NSPersistentStoreCoordinator
    
    public init(model:CoreDataModel, storeType:String = NSSQLiteStoreType, options:[NSObject:AnyObject]? = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true], concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {
        
        self.model = model
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model.managedObjectModel)
        
        let modelStoreURL:NSURL? = (storeType == NSInMemoryStoreType) ? nil : model.storeURL
        
        do {
            try self.persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: modelStoreURL, options: options)
        } catch _ as NSError {
        }
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    }
    
    public func childManagedObjectContext(concurrencyType:NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType, mergePolicyType:NSMergePolicyType = .MergeByPropertyObjectTrumpMergePolicyType) -> ChildManagedObjectContext {
        
        let childContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        childContext.parentContext = managedObjectContext
        childContext.mergePolicy = NSMergePolicy(mergeType: mergePolicyType)
        return childContext
    }
    
    public var description: String {
        get {
            return "<\(String(CoreDataStack.self)): model=\(model)>"
        }
    }
}
