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
    
    override init() {
        super.init()
        
        NSOperationQueue().addOperation(self)
    }
    
    override func main() {
        var venueCategories:[[String:AnyObject]] = [[String:AnyObject]]()
        FoursquareClient.sharedInstance().searchCategories() { success, result, errorString in
            if let error = errorString {
                println(error)
            } else {
                venueCategories = result!
            }
        }
        let realm = Realm(path: Realm.defaultPath)
        realm.write() {
            for category in venueCategories {
                let fCategory:FCategory = realm.create(FCategory.self, value: category, update: true)
            }
        }
    }
}
