//
//  CDUser.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDUser)

public class CDUser : NSManagedObject, Equatable, Printable {
    
    @NSManaged public var id:String
    @NSManaged public var firstName:String
    @NSManaged public var lastName:String
    @NSManaged public var type:String
    @NSManaged public var homeCity:String
    @NSManaged public var gender:String
    @NSManaged public var lastUpdate:NSDate
    @NSManaged public var photo:CDPhoto
    
    @NSManaged public var venueLists:[CDVenueList]
    
    override public var description:String {
        get {
            return "\(self.firstName) \(self.lastName)"
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(data:[String:AnyObject], context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.lastUpdate = NSDate()
    }
}

public func ==(lhs:CDUser, rhs:CDUser) -> Bool {
    return lhs.id == rhs.id
}