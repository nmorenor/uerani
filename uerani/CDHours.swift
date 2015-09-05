//
//  CDHours.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDHours)

public class CDHours : NSManagedObject, Hours {

    @NSManaged public var status:String
    @NSManaged public var isOpen:Bool
    @NSManaged public var timeframes:[CDTimeFrames]
    
    @NSManaged public var venue:CDVenue?
    
    public var c_timeFrames:GeneratorOf<TimeFrames> {
        get {
            var queue = Queue<TimeFrames>()
            for next in self.timeframes {
                queue.enqueue(next)
            }
            return GeneratorOf<TimeFrames>(queue.generate())
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(hours:FHours, context:NSManagedObjectContext) {
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
