//
//  VenueCategoriesOperation.swift
//  uerani
//
//  Created by nacho on 8/3/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

class VenueCategoriesOperation : NSOperation {
    
    private var semaphore = dispatch_semaphore_create(0)
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mergeChanges:", name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
        
        
        NSOperationQueue().addOperation(self)
    }
    
    lazy var sharedModelContext:NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().dataStack.childManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        }()
    
    func mergeChanges(notification:NSNotification) {
        var mainContext:NSManagedObjectContext = CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
        dispatch_async(dispatch_get_main_queue()) {
            println("Merging on main context")
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    override func main() {
        var topCategoriesPredicate = NSPredicate(format: "topCategory = %@", NSNumber(bool: true))
        let realm = Realm(path: Realm.defaultPath)
        
        var rCategories = realm.objects(FCategory).filter(topCategoriesPredicate)
        if rCategories.count > 0 {
            //we already have categories on local cache
            return
        }
        
        var venueCategories:[[String:AnyObject]] = [[String:AnyObject]]()
        FoursquareClient.sharedInstance().searchCategories() { success, result, errorString in
            if let error = errorString {
                println(error)
            } else {
                venueCategories = result!
            }
            self.unlock()
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        var categories:[FCategory] = [FCategory]()
        realm.write() {
            for category in venueCategories {
                let fCategory:FCategory = realm.create(FCategory.self, value: category, update: true)
                categories.append(fCategory)
            }
        }
        
        //save on core data
        for category in categories {
            let parentCategory = CDCategory(category: category, context: self.sharedModelContext)
            createChildrenCategories(parentCategory, categories: category.categories)
        }
        
        //save context
        saveContext(self.sharedModelContext) { success in
            self.unlock()
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func createChildrenCategories(parentCategory:CDCategory, categories:List<FSubCategory>) {
        for child in categories {
            var childCat = CDCategory(category: child, context: self.sharedModelContext)
            childCat.parentCategory = parentCategory
            if (child.categories.count > 0) {
                createChildrenCategories(childCat, categories: child.categories)
            }
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.sharedModelContext)
    }
}
