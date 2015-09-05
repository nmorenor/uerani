//
//  CDTimeFrames.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDTimeFrames)

public class CDTimeFrames : NSManagedObject {

    @NSManaged public var days:String
    @NSManaged public var open:[FTimeOpenFrames]
    
    @NSManaged public var hours:CDHours?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(timeFrames:FTimeFrames, context:NSManagedObjectContext) {
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
