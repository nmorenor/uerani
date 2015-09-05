//
//  CDSubCategory.swift
//  uerani
//
//  Created by nacho on 8/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDSubCategory)


public class CDSubCategory : CDCategory, Category {
    
    @NSManaged public var parentCategory:CDCategory?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(parentCategory: CDCategory, category:FCategory, context:NSManagedObjectContext) {
        super.init(category: category, context: context)
        self.parentCategory = parentCategory
    }
}