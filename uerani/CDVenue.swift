//
//  CDVenue.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDVenue)

public class CDVenue : NSManagedObject, Equatable, Venue {
    
    @NSManaged public var id:String
    @NSManaged public var name:String
    @NSManaged public var completeVenue:Bool
    @NSManaged public var contact:CDContact?
    @NSManaged public var location:CDLocation
    @NSManaged public var categories:[CDCategory]
    @NSManaged public var verified:Bool
    @NSManaged public var url:String
    @NSManaged public var tags:[CDTag]
    @NSManaged public var photos:[CDPhoto]
    @NSManaged public var bestPhoto:CDPhoto
    @NSManaged public var venueLists:[CDVenueList]
    @NSManaged public var rating:Float
    @NSManaged public var hours:CDHours?
    @NSManaged public var price:CDPrice?
    
    @NSManaged public var lastUpdate:NSDate
    
    public var c_contact:Contact? {
        return self.contact
    }
    
    public var c_bestPhoto:Photo? {
        return self.bestPhoto
    }
    
    public var c_price:Price? {
        return self.price
    }
    
    public var c_hours:Hours? {
        get {
            return self.hours
        }
    }
    
    public var c_location:Location? {
        get {
            return self.location
        }
    }
    
    public var c_categories:GeneratorOf<Category> {
        get {
            var queue = Queue<Category>()
            for next in self.categories {
                queue.enqueue(next)
            }
            return GeneratorOf<Category>(queue.generate())
        }
    }
    
    public var c_tags:GeneratorOf<Tag> {
        get {
            var queue = Queue<Tag>()
            for next in self.tags {
                queue.enqueue(next)
            }
            return GeneratorOf<Tag>(queue.generate())
        }
    }
    
    public var c_photos:GeneratorOf<Photo> {
        get {
            var queue = Queue<Photo>()
            for next in self.photos {
                queue.enqueue(next)
            }
            return GeneratorOf<Photo>(queue.generate())
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    //from cache data
    init(venue:FVenue, context:NSManagedObjectContext) {
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

public func ==(lhs:CDVenue, rhs:CDVenue) -> Bool {
    return lhs.id == rhs.id
}
