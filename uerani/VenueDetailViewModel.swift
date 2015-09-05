//
//  VenueDetailViewModel.swift
//  uerani
//
//  Created by nacho on 9/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class VenueDetailViewModel<T:Venue> {
    
    var name:String!
    var imageSize:CGSize!
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
    var price:String?
    var isOpen:Bool?
    var status:String?
    
    init(venue:T, imageSize:CGSize, delegate:VenueDetailsDelegate?) {
        self.imageSize = imageSize
        self.loadData(venue)
        if let delegate = delegate where !venue.completeVenue {
            VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
        } else if venue.c_bestPhoto == nil {
            VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
        } else {
            if let identifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: venue.c_bestPhoto!) {
                var image = ImageCache.sharedInstance().imageWithIdentifier(identifier)
                if image == nil {
                    VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
                }
            } else {
                VenueDetailOperation(venueId: venue.id, imageSize: imageSize, delegate: delegate)
            }
        }
    }
    
    static func getBestPhotoIdentifier(venueId:String, imageSize:CGSize, bestPhoto:Photo) -> String? {
        var size = "\(imageSize.width.getIntValue())x\(imageSize.height.getIntValue())"
        let url = NSURL(string: "\(bestPhoto.iprefix)\(size)\(bestPhoto.isuffix)")!
        if let identifier = getImageIdentifier(url) {
            return "venue_\(venueId)_\(size)_\(identifier)"
        }
        return nil
    }
    
    func loadData(venue:T) {
        self.name = venue.name
        self.rating = venue.rating
        self.loadContactData(venue)
        self.loadLocationData(venue)
        self.loadTagData(venue)
        self.loadPriceData(venue)
        
        if let hours = venue.c_hours {
            if !hours.status.isEmpty {
                self.status = hours.status
            }
            self.isOpen = hours.isOpen
        }
        
        if let bestPhoto = venue.c_bestPhoto {
            self.photoIdentifier = VenueDetailViewModel.getBestPhotoIdentifier(venue.id, imageSize:imageSize, bestPhoto: bestPhoto)
        }
    }
    
    private func loadPriceData(venue:T) {
        if let price = venue.c_price {
            if !price.message.isEmpty {
                self.price = price.message
            }
        }
    }
    
    private func loadTagData(venue:T) {
        var tags = [String]()
        for tag in venue.c_tags {
            tags.append(tag.tagvalue)
        }
        self.tags = tags
    }
    
    private func loadLocationData(venue:T) {
        if let location = venue.c_location {
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
    
    private func loadContactData(venue:T) {
        if let contact = venue.c_contact {
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
