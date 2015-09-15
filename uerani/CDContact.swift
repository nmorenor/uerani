//
//  CDContact.swift
//  uerani
//
//  Created by nacho on 8/28/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDContact)

public class CDContact : NSManagedObject, Contact {
    
    @NSManaged public var phone:String
    @NSManaged public var formattedPhone:String
    @NSManaged public var email:String
    
    @NSManaged public var venue:CDVenue?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(contact:FContact, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.phone = contact.phone
        self.formattedPhone = contact.formattedPhone
        self.email = contact.email
    }
}
