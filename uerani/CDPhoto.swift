//
//  CDPhoto.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDPhoto)

public class CDPhoto : NSManagedObject, Equatable {
    
    @NSManaged public var id:String
    @NSManaged public var prefix:String
    @NSManaged public var suffix:String
    @NSManaged public var visibility:String
    
    @NSManaged public var venue:CDVenue?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(photo:FPhoto, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        

    }
    
    init(data:[String:AnyObject], context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //TODO
    }
}

public func ==(lhs:CDPhoto, rhs:CDPhoto) -> Bool {
    return lhs.id == rhs.id
}