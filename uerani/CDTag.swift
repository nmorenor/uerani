//
//  CDTag.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDTag)

public class CDTag : NSManagedObject, Tag {
    
    @NSManaged public var tagvalue:String
    
    @NSManaged public var venues:NSMutableSet
    
    override public var description:String {
        get {
            return "\(self.tagvalue)"
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(tag:FTag, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.tagvalue = tag.tagvalue
    }
}
