//
//  CDUser.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

@objc(CDUser)

public class CDUser : NSManagedObject, Equatable, Printable {
    
    @NSManaged public var id:String
    @NSManaged public var firstName:String
    @NSManaged public var lastName:String
    @NSManaged public var homeCity:String
    @NSManaged public var gender:String
    @NSManaged public var lastUpdate:NSDate
    @NSManaged public var photo:CDPhoto?
    
    @NSManaged public var venueLists:[CDVenueList]
    
    override public var description:String {
        get {
            return "\(self.firstName) \(self.lastName)"
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(result:[String:AnyObject], context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.id = result[FoursquareClient.RespnoseKeys.ID] as! String
        
        if let firstName = result[FoursquareClient.RespnoseKeys.FIRST_NAME] as? String {
            self.firstName = firstName
        } else {
            self.firstName = ""
        }
        if let lastName = result[FoursquareClient.RespnoseKeys.LAST_NAME] as? String {
            self.lastName = lastName
        } else {
            self.lastName = ""
        }
        if let homeCity = result[FoursquareClient.RespnoseKeys.HOME_CITY] as? String {
            self.homeCity = homeCity
        } else {
            self.homeCity = ""
        }
        if let gender = result[FoursquareClient.RespnoseKeys.GENDER] as? String {
            self.gender = gender
        } else {
            self.gender = ""
        }
        if let photo = result[FoursquareClient.RespnoseKeys.PHOTO] as? [String:AnyObject] {
            if let cPhoto = self.photo {
                cPhoto.prefix = photo[FoursquareClient.RespnoseKeys.PREFIX] as! String
                cPhoto.suffix = photo[FoursquareClient.RespnoseKeys.SUFFIX] as! String
            } else {
                var cPhoto = CDPhoto(data: photo, context: context)
                cPhoto.user = self
                self.photo = cPhoto
            }
        } else {
            if let photo = self.photo {
                self.photo = nil
                context.deleteObject(photo)
            }
        }
        self.lastUpdate = NSDate()
    }
}

public func ==(lhs:CDUser, rhs:CDUser) -> Bool {
    return lhs.id == rhs.id
}