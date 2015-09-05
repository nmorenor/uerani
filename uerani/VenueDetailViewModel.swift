//
//  VenueDetailViewModel.swift
//  uerani
//
//  Created by nacho on 9/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class VenueDetailViewModel {
    
    var name:String!
    var email:String?
    var phone:String?
    var address:String?
    var conuntry:String?
    var state:String?
    var city:String?
    var postalCode:String?
    var tags:[String]?
    var rating:Float!
    var photoIdentifier:String?
    
    init(venueId:String, realm:Realm, imageSize:CGSize, delegate:VenueDetailsDelegate?) {
        let venue = realm.objectForPrimaryKey(FVenue.self, key: venueId)!
        self.loadData(venue, imageSize:imageSize)
        if let delegate = delegate where !venue.completeVenue {
            VenueDetailOperation(venueId: venueId, imageSize: imageSize, delegate: delegate)
        } else if venue.bestPhoto == nil {
            VenueDetailOperation(venueId: venueId, imageSize: imageSize, delegate: delegate)
        } else {
            if let identifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: venue.bestPhoto!) {
                var image = ImageCache.sharedInstance().imageWithIdentifier(identifier)
                if image == nil {
                    VenueDetailOperation(venueId: venueId, imageSize: imageSize, delegate: delegate)
                }
            } else {
                VenueDetailOperation(venueId: venueId, imageSize: imageSize, delegate: delegate)
            }
        }
    }
    
    static func getBestPhotoIdentifier(venueId:String, imageSize:CGSize, bestPhoto:FPhoto) -> String? {
        var size = "\(imageSize.width.getIntValue())x\(imageSize.height.getIntValue())"
        var identifier = getImageIdentifier(size, bestPhoto)
        if let identifier = identifier {
            return "venue_\(venueId)_\(size)_\(identifier)"
        }
        return nil
    }
    
    func loadData(venue:FVenue, imageSize:CGSize) {
        self.name = venue.name
        self.rating = venue.rating
        self.loadContactData(venue)
        self.loadLocationData(venue)
        self.loadTagData(venue)
        
        if let bestPhoto = venue.bestPhoto {
            self.photoIdentifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: bestPhoto)
        }
    }
    
    func loadTagData(venue:FVenue) {
        if venue.tags.count > 0 {
            var tags = [String]()
            for tag in venue.tags {
                tags.append(tag.tagvalue)
            }
            self.tags = tags
        }
    }
    
    func loadLocationData(venue:FVenue) {
        if let location = venue.location {
            if !location.address.isEmpty {
                self.address = location.address
            }
            if !location.city.isEmpty {
                self.city = location.city
            }
            if !location.country.isEmpty {
                self.conuntry = location.country
            }
            if !location.state.isEmpty {
                self.state = location.state
            }
            if !location.postalCode.isEmpty {
                self.postalCode = location.postalCode
            }
        }
    }
    
    func loadContactData(venue:FVenue) {
        if let contact = venue.contact {
            if !contact.email.isEmpty {
                self.email = contact.email
            }
            if !contact.formattedPhone.isEmpty {
                self.phone = contact.formattedPhone
            } else if !contact.phone.isEmpty {
                self.phone = contact.phone
            }
        }
    }
}
