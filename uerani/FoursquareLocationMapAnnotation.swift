//
//  FoursquareLocationMapAnnotation.swift
//  grabbed
//
//  Created by nacho on 7/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit

class FoursquareLocationMapAnnotation: NSObject, MKAnnotation, Hashable, Equatable {
   
    let title:String
    let subtitle:String
    let coordinate:CLLocationCoordinate2D
    var categoryImageName:String?
    var categoryImagePinName:String?
    var categoryPrefix:String?
    var categorySuffix:String?
    weak var venue:FVenue?
    
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
    
    init(venue:FVenue) {
        self.title = venue.name
        self.subtitle = ""
        
        self.coordinate = CLLocationCoordinate2D(latitude: venue.location.lat, longitude: venue.location.lng)
        self.venue = venue
        if let category = venue.categories.first, let url = NSURL(string: "\(category.icon.prefix)\(FIcon.FIconSize.S32.description)\(category.icon.suffix)"), let name = url.lastPathComponent {
            categoryImageName = name
            
            let pathExtension = name.pathExtension
            let pathPrefix = name.stringByDeletingPathExtension
            
            //protect from bad data from API
            if "png" == pathExtension {
                categoryImagePinName = "\(pathPrefix)-pin.\(pathExtension)"
            } else {
                categoryImagePinName = "default_32-pin.png"
            }
            
            self.categoryPrefix = category.icon.prefix
            self.categorySuffix = category.icon.suffix
            
        }
    }
    
    private func calculateHashValue() -> Int {
        let prime:Int = 31
        var result:Int = 1
        var toHash = NSString(format: "[%.8f,%.8f]", coordinate.latitude, coordinate.longitude)
        result = prime * result + toHash.hashValue
        return result
    }
}

func ==(lhs: FoursquareLocationMapAnnotation, rhs:FoursquareLocationMapAnnotation) -> Bool {
    return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
}
