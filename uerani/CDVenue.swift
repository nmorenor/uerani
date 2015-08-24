//
//  CDVenue.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDVenue)

public class CDVenue : NSManagedObject, Equatable {
    
    @NSManaged public var id:String
    @NSManaged public var name:String
    @NSManaged public var completeVenue:Bool
    @NSManaged public var contact:CDContact?
    @NSManaged public var location:CDLocation
    @NSManaged public var categories:NSSet
    @NSManaged public var verified:Bool
    @NSManaged public var url:String
    @NSManaged public var tags:NSSet
    @NSManaged public var photos:NSSet
    
    @NSManaged public var lastUpdate:NSDate
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //from cache data
    init(venue:FVenue, context:NSManagedObjectContext) {
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

public func ==(lhs:CDVenue, rhs:CDVenue) -> Bool {
    return lhs.id == rhs.id
}
