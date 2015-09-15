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
    
    public var c_open:GeneratorOf<TimeOpenFrames> {
        get {
            var queue = Queue<TimeOpenFrames>()
            for next in open {
                queue.enqueue(next)
            }
            return GeneratorOf<TimeOpenFrames>(queue.generate())
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
        
        var ourFrames:[CDTimeOpenFrames] = [CDTimeOpenFrames]()
        for nextFrame in timeFrames.open {
            var openFrame = CDTimeOpenFrames(openFrames: nextFrame, context: context)
            openFrame.timeFrames = self
            ourFrames.append(openFrame)
        }
        self.open = ourFrames
    }
}
