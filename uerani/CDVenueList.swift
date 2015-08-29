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

public class CDVenueList : NSManagedObject {
    
    @NSManaged public var venues:[CDVenue]
    @NSManaged public var user:CDUser?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
