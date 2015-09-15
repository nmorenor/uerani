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
    @NSManaged public var bestPhoto:CDPhoto?
    @NSManaged public var venueLists:[CDVenueList]
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
        
        var categories = [CDCategory]()
        for nextCat in venue.categories {
            var category = CDVenue.getCategory(nextCat, context: context)
            if let category = category {
                category.venues.append(cvenue)
                categories.append(category)
            }
        }
        cvenue.categories = categories
        cvenue.url = venue.url
        
        var tags = [CDTag]()
        for nextTag in venue.tags {
            var tag = CDVenue.getTag(nextTag, context: context)
            tag.venues.append(cvenue)
            tags.append(tag)
        }
        cvenue.tags = tags
        
        var photos = [CDPhoto]()
        for nextPhoto in venue.photos {
            var photo = CDVenue.getPhoto(nextPhoto, context: context)
            photo.venue = cvenue
            photos.append(photo)
        }
        //this is not required :)
        cvenue.photos = photos
        
        if let bestPhoto = cvenue.bestPhoto {
            bestPhoto.venueBestPhoto = nil
        }
        
        if let bestPhoto = venue.bestPhoto {
            cvenue.bestPhoto = CDVenue.getPhoto(bestPhoto, context: context)
            cvenue.bestPhoto!.venueBestPhoto = cvenue
        }
        cvenue.rating = venue.rating
        
        if let hours = cvenue.hours {
            if let fhours = venue.hours {
                hours.status = fhours.status
                hours.isOpen = fhours.isOpen
                for next in hours.timeframes {
                    next.hours = nil
                    context.delete(next)
                }
                for nextFrame in fhours.timeframes {
                    var frame = CDTimeFrames(timeFrames: nextFrame, context: context)
                    frame.hours = hours
                }
            } else {
                cvenue.hours = nil
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
                cvenue.price = nil
                context.delete(price)
            }
        } else if let fprice = venue.price {
            cvenue.price = CDPrice(price: fprice, context: context)
            cvenue.price!.venue = cvenue
        }
        
        cvenue.venueDescription = venue.venueDescription
    }
    
    static func getPhoto(photo:FPhoto, context:NSManagedObjectContext) -> CDPhoto {
        let fetchRequest = NSFetchRequest(entityName: "CDPhoto")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id", photo.id)
        
        var error:NSError? = nil
        var results = context.executeFetchRequest(fetchRequest, error: &error)
        var result:CDPhoto!
        if let error = error {
            println("can not find photo \(photo.id)")
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
        fetchRequest.predicate = NSPredicate(format: "tagvalue", tag.tagvalue)
        
        var error:NSError? = nil
        var results = context.executeFetchRequest(fetchRequest, error: &error)
        
        var result:CDTag!
        if let error = error {
            println("can not find tag \(tag.tagvalue)")
            result = CDTag(tag: tag, context: context)
        } else if let results = results where !results.isEmpty {
            result = results.first as? CDTag
        } else {
            result = CDTag(tag: tag, context: context)
        }
        return result
    }
    
    static func getCategory(category:FCategory, context:NSManagedObjectContext) -> CDCategory? {
        let fetchRequest = NSFetchRequest(entityName: "CDCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id", category.id)
        
        var error:NSError? = nil
        var results = context.executeFetchRequest(fetchRequest, error: &error)
        
        var result:CDCategory? = nil
        if let error = error {
            println("can not find category \(category.id)")
        } else if let results = results where !results.isEmpty {
            result = results.first as? CDCategory
        }
        return result
    }
}

public func ==(lhs:CDVenue, rhs:CDVenue) -> Bool {
    return lhs.id == rhs.id
}
