//
//  CDCategory.swift
//  uerani
//
//  Created by nacho on 8/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDCategory)

public class CDCategory : NSManagedObject, Equatable, Hashable, Printable, IconCapable, Category {
    
    @NSManaged public var id:String
    @NSManaged public var name:String
    @NSManaged public var pluralName:String
    @NSManaged public var shortName:String
    @NSManaged public var icon:CDIcon
    @NSManaged public var primary:Bool
    @NSManaged public var topCategory:Bool
    @NSManaged public var categories:[CDSubCategory]
    
    @NSManaged public var venues:[CDVenue]
    
    override public var description:String {
        get {
            return self.name
        }
    }
    
    override public var hashValue:Int {
        get {
            return self.id.hashValue
        }
    }
    
    public var iprefix:String {
        get {
            return self.icon.prefix
        }
    }
    public var isuffix:String {
        get {
            return self.icon.suffix
        }
    }
    
    public var c_categories:GeneratorOf<Category> {
        get {
            var queue = Queue<Category>()
            for next in categories {
                queue.enqueue(next)
            }
            return GeneratorOf<Category>(queue.generate())
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(category:FCategory, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = category.id
        self.name = category.name
        self.pluralName = category.pluralName
        self.shortName = category.shortName
        self.icon = CDIcon(icon: category.icon!, context: context)
        self.primary = category.primary
        self.topCategory = category.topCategory
    }
}

public func ==(lhs:CDCategory, rhs:CDCategory) -> Bool {
    return lhs.id == rhs.id
}
