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

class VenueCategoriesOperation : AbstractCoreDataOperation {
    
    weak var delegate:CategoriesReady?
    var foursquareApiSemaphore = dispatch_semaphore_create(0)
    
    init(delegate:CategoriesReady) {
        self.delegate = delegate;
        super.init(operationQueue: NSOperationQueue())
    }
    
    override func main() {
        let topCategoriesPredicate = NSPredicate(format: "topCategory = %@", NSNumber(bool: true))
        let realm = try! Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        
        let rCategories = realm.objects(FCategory).filter(topCategoriesPredicate)
        if rCategories.count > 0 {
            //we already have categories on local cache, look for any category that has pending image download
            let results = realm.objects(FCategory)
            for nextCat in results {
                var downloadCategoryImage = true
                if let imageid = getImageIdentifier(FIcon.FIconSize.S32.description, iconCapable: nextCat), let _ = ImageCache.sharedInstance().imageWithIdentifier(imageid) {
                    downloadCategoryImage = false
                }
                if downloadCategoryImage {
                    _ = FoursquareCategoryIconWorker(prefix: nextCat.icon!.prefix, suffix: nextCat.icon!.suffix)
                }
            }
            self.delegate?.initializeSearchResults()
            return
        }
        
        var venueCategories:[[String:AnyObject]] = [[String:AnyObject]]()
        FoursquareClient.sharedInstance().searchCategories() { success, result, errorString in
            if let error = errorString {
                if DEBUG {
                    Swift.print(error, terminator: "")
                }
            } else {
                venueCategories = result!
            }
            self.unlockFoursquareAPISemephore()
        }
        
        dispatch_semaphore_wait(foursquareApiSemaphore, DISPATCH_TIME_FOREVER)
        
        var categories:[FCategory] = [FCategory]()
        try! realm.write() {
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
    
    func unlockFoursquareAPISemephore() {
        dispatch_semaphore_signal(foursquareApiSemaphore)
    }
    
    func createChildrenCategories(parentCategory:CDCategory, categories:List<FSubCategory>) {
        for child in categories {
            let childCat = CDSubCategory(parentCategory: parentCategory, category: child, context: self.sharedModelContext)
            if (child.categories.count > 0) {
                createChildrenCategories(childCat, categories: child.categories)
            }
        }
    }
}
