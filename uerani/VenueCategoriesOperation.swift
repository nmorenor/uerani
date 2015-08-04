//
//  VenueCategoriesOperation.swift
//  uerani
//
//  Created by nacho on 8/3/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

class VenueCategoriesOperation : NSOperation {
    
    private var semaphore = dispatch_semaphore_create(0)
    
    override init() {
        super.init()
        
        NSOperationQueue().addOperation(self)
    }
    
    override func main() {
        var topCategoriesPredicate = NSPredicate(format: "topCategory = %@", NSNumber(bool: true))
        let realm = Realm(path: Realm.defaultPath)
        
        var rCategories = realm.objects(FCategory).filter(topCategoriesPredicate)
        if rCategories.count > 0 {
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
        
        realm.write() {
            for category in venueCategories {
                let fCategory:FCategory = realm.create(FCategory.self, value: category, update: true)
                println(fCategory.topCategory)
            }
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
}
