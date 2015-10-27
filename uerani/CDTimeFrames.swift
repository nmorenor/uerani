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

public class CDTimeFrames : NSManagedObject, TimeFrames {

    @NSManaged public var days:String
    @NSManaged public var open:[CDTimeOpenFrames]
    
    @NSManaged public var hours:CDHours?
    
    public var c_open:AnyGenerator<TimeOpenFrames> {
        get {
            let queue = Queue<TimeOpenFrames>()
            for next in open {
                queue.enqueue(next)
            }
            return anyGenerator(queue.generate())
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(timeFrames:FTimeFrames, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.days = timeFrames.days

        for nextFrame in timeFrames.open {
            let openFrame = CDTimeOpenFrames(openFrames: nextFrame, context: context)
            openFrame.timeFrames = self
        }
    }
}
