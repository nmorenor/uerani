//
//  CoreDataModel.swift
//  Virtual Tourist
//
//  Created by nacho on 6/8/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

public typealias ContextSaveResult = (success: Bool, error: NSError?)

public struct CoreDataModel: Printable {
    
    public let name:String
    public let bundle:NSBundle
    public let storeDirectoryURL:NSURL
    
    public var storeURL: NSURL {
        get {
            return storeDirectoryURL.URLByAppendingPathComponent(databaseFileName)
        }
    }
    
    public var modelURL:NSURL {
        get {
            let url = bundle.URLForResource(name, withExtension: "momd")
            return url!
        }
    }
    
    public var databaseFileName: String {
        get {
            return name + ".sqlite"
        }
    }
    
    public var managedObjectModel : NSManagedObjectModel {
        get {
            let model = NSManagedObjectModel(contentsOfURL: modelURL)
            return model!
        }
    }
    
    public var modelStoreNeedsMigration:Bool {
        get {
            var error:NSError?
            if let sourceMetaData = NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(nil, URL: storeURL, error: &error) {
                return !managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: sourceMetaData)
            }
            println("*** \(toString(CoreDataModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Failure checking persistent store coordinator meta data: \(error)")
            return false
        }
    }
    
    public init(name:String, bundle:NSBundle = NSBundle.mainBundle(), storeDirectoryURL: NSURL = documentsDirectoryURL()) {
        self.name = name
        self.bundle = bundle
        self.storeDirectoryURL = storeDirectoryURL
    }
    
    public func removeExistingModelStore() -> (success:Bool, error:NSError?) {
        var error:NSError?
        let fileManager = NSFileManager.defaultManager()
        
        if let storePath = storeURL.path {
            if fileManager.fileExistsAtPath(storePath) {
                let success = fileManager.removeItemAtURL(storeURL, error: &error)
                if !success {
                    println("*** \(toString(CoreDataModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Could not remove model store at url: \(error)")
                }
                return (success, error)
            }
        }
        
        return (false, nil)
    }
    
    public var description:String {
        get {
            return "<\(toString(CoreDataModel.self)): name=\(name), needsMigration=\(modelStoreNeedsMigration), databaseFileName=\(databaseFileName), modelURL=\(modelURL), storeURL=\(storeURL)>"
        }
    }
}

public func saveContext(context: NSManagedObjectContext, completion: (ContextSaveResult) -> Void) {
    if !context.hasChanges {
        completion((true, nil))
        return
    }
    
    context.performBlock { () -> Void in
        var error: NSError?
        let success = context.save(&error)
        
        if !success {
            println("*** ERROR: [\(__LINE__)] \(__FUNCTION__) Could not save managed object context: \(error)")
        }
        
        completion((success, error))
    }
}

// MARK: Private

public func documentsDirectoryURL() -> NSURL {
    var error: NSError?
    let url = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
    assert(url != nil, "*** Error finding documents directory: \(error)")
    return url!
}
