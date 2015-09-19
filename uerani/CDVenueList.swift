//
//  CDVenueList.swift
//  uerani
//
//  Created by nacho on 8/28/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDVenueList)

public class CDVenueList : NSManagedObject, Equatable, Hashable, Printable {
    
    @NSManaged public var venues:NSMutableSet
    @NSManaged public var user:CDUser
    
    @NSManaged public var title:String
    
    override public var hashValue:Int {
        get {
            let prime:Int = 31
            var result:Int = 1
            result = prime * result + self.user.hashValue
            result = prime * result + self.title.hashValue
            return result
        }
    }
    
    override public var description:String {
        get {
            return "list_\(self.user.id)_\(self.title)"
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(title:String, user:CDUser, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = title
        self.user = user
    }
}

public func ==(lhs:CDVenueList, rhs:CDVenueList) -> Bool {
    return lhs.title == rhs.title && lhs.user == rhs.user
}
