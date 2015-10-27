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

public class CDVenue : NSManagedObject, Venue {
    
    @NSManaged public var id:String
    @NSManaged public var name:String
    @NSManaged public var completeVenue:Bool
    @NSManaged public var contact:CDContact?
    @NSManaged public var location:CDLocation
    @NSManaged public var categories:NSMutableSet
    @NSManaged public var verified:Bool
    @NSManaged public var url:String
    @NSManaged public var tags:NSMutableSet
    @NSManaged public var photos:[CDPhoto]
    @NSManaged public var bestPhoto:CDPhoto?
    @NSManaged public var venueLists:NSMutableSet
    @NSManaged public var rating:Float
    @NSManaged public var hours:CDHours?
    @NSManaged public var price:CDPrice?
    @NSManaged public var venueDescription:String
    
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
    
    public var c_categories:AnyGenerator<Category> {
        get {
            let queue = Queue<Category>()
            for next in self.categories.allObjects {
                queue.enqueue(next as! CDCategory)
            }
            return anyGenerator(queue.generate())
        }
    }
    
    public var c_tags:AnyGenerator<Tag> {
        get {
            let queue = Queue<Tag>()
            for next in self.tags.allObjects {
                queue.enqueue(next as! CDTag)
            }
            return anyGenerator(queue.generate())
        }
    }
    
    public var c_photos:AnyGenerator<Photo> {
        get {
            let queue = Queue<Photo>()
            for next in self.photos {
                queue.enqueue(next)
            }
            return anyGenerator(queue.generate())
        }
    }
    
    override public var hashValue:Int {
        get {
            return self.id.hashValue
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(venue:FVenue, context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = venue.id
    }
    
    static func updateVenue(cvenue:CDVenue, venue:FVenue, context:NSManagedObjectContext) {
        cvenue.name = venue.name
        cvenue.completeVenue = venue.completeVenue
        if let contact = venue.contact {
            cvenue.contact = CDContact(contact: contact, context: context)
            cvenue.contact!.venue = cvenue
        }
        if let location = venue.location {
            cvenue.location = CDLocation(location: location, context: context)
            cvenue.location.venue = cvenue
        }
        cvenue.verified = venue.verified
        cvenue.url = venue.url
        
        for nextPhoto in venue.photos {
            let photo = CDVenue.getPhoto(nextPhoto, context: context)
            photo.venue = cvenue
        }
        
        if let bestPhoto = cvenue.bestPhoto {
            bestPhoto.venueBestPhoto = nil
        }
        
        if let fbestPhoto = venue.bestPhoto {
            cvenue.bestPhoto = CDVenue.getPhoto(fbestPhoto, context: context)
            cvenue.bestPhoto!.venueBestPhoto = cvenue
        }
        cvenue.rating = venue.rating
        
        if let hours = cvenue.hours {
            if let fhours = venue.hours {
                hours.status = fhours.status
                hours.isOpen = fhours.isOpen
                for next in hours.timeframes {
                    context.delete(next)
                }
                for nextFrame in fhours.timeframes {
                    let frame = CDTimeFrames(timeFrames: nextFrame, context: context)
                    frame.hours = hours
                }
            } else {
                context.delete(hours)
            }
        } else if let fhours = venue.hours {
            cvenue.hours = CDHours(hours: fhours, context: context)
            cvenue.hours?.venue = cvenue
        }
        
        if let price = cvenue.price {
            if let fprice = venue.price {
                price.tier = fprice.tier
                price.message = fprice.message
            } else {
                context.delete(price)
            }
        } else if let fprice = venue.price {
            cvenue.price = CDPrice(price: fprice, context: context)
            cvenue.price!.venue = cvenue
        }
        
        cvenue.venueDescription = venue.venueDescription
        cvenue.lastUpdate = NSDate()
        
        CDVenue.updateVenueCategoriesAndTags(cvenue, venue: venue, context: context)
    }
    
    static func updateVenueCategoriesAndTags(cvenue:CDVenue, venue:FVenue, context:NSManagedObjectContext) {
        for nextCat in venue.categories {
            let category = CDVenue.getCategory(nextCat, context: context)
            if let category = category {
                category.venues.addObject(cvenue)
                cvenue.categories.addObject(category)
            }
        }
        
        for nextTag in venue.tags {
            let tag = CDVenue.getTag(nextTag, context: context)
            tag.venues.addObject(cvenue)
            cvenue.tags.addObject(tag)
        }
    }
    
    static func getPhoto(photo:FPhoto, context:NSManagedObjectContext) -> CDPhoto {
        let fetchRequest = NSFetchRequest(entityName: "CDPhoto")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id = %@", photo.id)
        
        var error:NSError? = nil
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        var result:CDPhoto!
        if let _ = error {
            if DEBUG {
                print("can not find photo \(photo.id)")
            }
            result = CDPhoto(photo: photo, context: context)
        } else if let results = results where !results.isEmpty {
            result = results.first as? CDPhoto
        } else {
            result = CDPhoto(photo: photo, context: context)
        }
        return result
    }
    
    static func getTag(tag:FTag, context:NSManagedObjectContext) -> CDTag {
        let fetchRequest = NSFetchRequest(entityName: "CDTag")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "tagvalue", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "tagvalue = %@", tag.tagvalue)
        
        var error:NSError? = nil
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        
        var result:CDTag!
        if let _ = error {
            if DEBUG {
                print("can not find tag \(tag.tagvalue)")
            }
            result = CDTag(tag: tag, context: context)
        } else if let results = results where !results.isEmpty {
            result = results.first as! CDTag
        } else {
            result = CDTag(tag: tag, context: context)
        }
        return result
    }
    
    static func getCategory(category:FCategory, context:NSManagedObjectContext) -> CDCategory? {
        let fetchRequest = NSFetchRequest(entityName: "CDCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id = %@", category.id)
        
        var error:NSError? = nil
        var results: [AnyObject]?
        do {
            results = try context.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        
        var result:CDCategory? = nil
        if let _ = error {
            if DEBUG {
                print("can not find category \(category.id)")
            }
        } else if let results = results where !results.isEmpty {
            result = results.first as? CDCategory
        }
        return result
    }
}

public func ==(lhs:CDVenue, rhs:CDVenue) -> Bool {
    return lhs.id == rhs.id
}
