//
//  CDIcon.swift
//  uerani
//
//  Created by nacho on 8/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDIcon)

public class CDIcon : NSManagedObject, Icon {
    
    @NSManaged public var prefix:String
    @NSManaged public var suffix:String
    @NSManaged public var category:CDCategory?
    
    override public var description:String {
        get {
            return "\(prefix)-\(suffix)"
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(icon:FIcon, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.prefix = icon.prefix
        self.suffix = icon.suffix
    }
}

public func ==(lhs:CDIcon, rhs:CDIcon) -> Bool {
    return lhs.description == rhs.description
}
