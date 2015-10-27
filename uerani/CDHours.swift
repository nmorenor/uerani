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
    
    public var c_timeFrames:AnyGenerator<TimeFrames> {
        get {
            let queue = Queue<TimeFrames>()
            for next in self.timeframes {
                queue.enqueue(next)
            }
            return anyGenerator(queue.generate())
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(hours:FHours, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.status = hours.status
        self.isOpen = hours.isOpen
        
        for nextTimeFrame in hours.timeframes {
            let frame = CDTimeFrames(timeFrames: nextTimeFrame, context: context)
            frame.hours = self
        }
    }
    
}
