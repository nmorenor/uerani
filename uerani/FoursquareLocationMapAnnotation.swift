//
//  FoursquareLocationMapAnnotation.swift
//  uerani
//
//  Created by nacho on 7/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit

class FoursquareLocationMapAnnotation: NSObject, MKAnnotation {
   
    let title:String?
    let subtitle:String?
    let coordinate:CLLocationCoordinate2D
    var categoryImageName:String?
    var categoryImageName8:String?
    var categoryImageName12:String?
    var categoryImageName64:String?
    var categoryPrefix:String?
    var categorySuffix:String?
    var venueId:String
    var city:String
    var state:String
    weak var venue:Venue?
    
    override var hashValue: Int {
        get {
            return self.calculateHashValue()
        }
    }
    
    //override nsobject equatable, used to display annotations
    override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? FoursquareLocationMapAnnotation {
            return self == other
        }
        return false
    }
    
    //override nsobject hash, used to display annotations
    override var hash: Int {
        return self.hashValue
    }
    
    init(venueAnnotation:FVenueMapAnnotation) {
        self.title = venueAnnotation.title
        self.subtitle = venueAnnotation.subtitle
        self.city = venueAnnotation.city
        self.state = venueAnnotation.state
        self.venueId = venueAnnotation.venueId
        self.coordinate = venueAnnotation.coordinate
        self.categoryImageName = venueAnnotation.categoryImageName
        self.categoryImageName8 = venueAnnotation.categoryImageName8
        self.categoryImageName12 = venueAnnotation.categoryImageName12
        self.categoryImageName64 = venueAnnotation.categoryImageName64
        self.categoryPrefix = venueAnnotation.categoryPrefix
        self.categorySuffix = venueAnnotation.categorySuffix
    }
    
    init(venue:Venue) {
        self.title = venue.name
        self.subtitle = venue.c_location!.address
        self.state = venue.c_location!.state
        self.city = venue.c_location!.city
        self.venueId = venue.id
        
        self.coordinate = CLLocationCoordinate2D(latitude: venue.c_location!.lat, longitude: venue.c_location!.lng)
        self.venue = venue
        if let category = FoursquareLocationMapAnnotation.getBestCategory(venue) {
            categoryImageName = getImageIdentifier(FIcon.FIconSize.S32.description, iconCapable: category)
            categoryImageName64 = getImageIdentifier(FIcon.FIconSize.S64.description, iconCapable: category)
            categoryImageName12 = getImageIdentifier("12", iconCapable: category)
            categoryImageName8 = getImageIdentifier("8", iconCapable: category)
            
            self.categoryPrefix = category.c_icon!.prefix
            self.categorySuffix = category.c_icon!.suffix
        }
    }
    
    private func calculateHashValue() -> Int {
        let prime:Int = 31
        var result:Int = 1
        let toHash = NSString(format: "[%.8f,%.8f]", coordinate.latitude, coordinate.longitude)
        result = prime * result + toHash.hashValue
        return result
    }
    
    private static func getBestCategory(venue:Venue) -> Category? {
        for nextCat in venue.c_categories {
            if let url = NSURL(string: "\(nextCat.c_icon!.prefix)\(FIcon.FIconSize.S32.description)\(nextCat.c_icon!.suffix)"), let imageName = getImageIdentifier(url) {
                if let _ = ImageCache.sharedInstance().imageWithIdentifier(imageName) {
                    return nextCat
                }
            }
        }
        for nextCat in venue.c_categories {
            return nextCat
        }
        return nil
    }
}

func ==(lhs: FoursquareLocationMapAnnotation, rhs:FoursquareLocationMapAnnotation) -> Bool {
    return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
}
