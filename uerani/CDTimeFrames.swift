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
    @NSManaged public var open:[FTimeOpenFrames]
    
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
        
    }
    
    init(data:[String:AnyObject], context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        //TODO
    }
}
