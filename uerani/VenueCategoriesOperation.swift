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
    weak var delegate:CategoriesReady?
    
    init(delegate:CategoriesReady) {
        self.delegate = delegate;
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
            mainContext.mergeChangesFromContextDidSaveNotification(notification)
            saveContext(CoreDataStackManager.sharedInstance().dataStack.managedObjectContext) { success, error in 
                self.delegate?.initializeSearchResults()
                self.unlock()
            }
        }
    }
    
    override func main() {
        var topCategoriesPredicate = NSPredicate(format: "topCategory = %@", NSNumber(bool: true))
        let realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        
        var rCategories = realm.objects(FCategory).filter(topCategoriesPredicate)
        if rCategories.count > 0 {
            //we already have categories on local cache, look for any category that has pending image download
            let results = realm.objects(FCategory)
            for nextCat in results {
                if let url = NSURL(string: "\(nextCat.icon!.prefix)\(FIcon.FIconSize.S32.description)\(nextCat.icon!.suffix)"), let name = url.lastPathComponent, let pathComponents = url.pathComponents {
                    let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
                    let imageName = "\(prefix_image_name)_\(name)"
                    var image = ImageCache.sharedInstance().imageWithIdentifier(imageName)
                    if image == nil {
                        FoursquareCategoryIconWorker(prefix: nextCat.icon!.prefix, suffix: nextCat.icon!.suffix)
                    }
                }
            }
            self.delegate?.initializeSearchResults()
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
        
        //save context and wait
        saveContext(self.sharedModelContext) { success in
            //do nothing
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func createChildrenCategories(parentCategory:CDCategory, categories:List<FSubCategory>) {
        for child in categories {
            var childCat = CDSubCategory(parentCategory: parentCategory, category: child, context: self.sharedModelContext)
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
