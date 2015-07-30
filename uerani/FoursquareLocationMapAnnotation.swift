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
        if let category = FoursquareLocationMapAnnotation.getBestCategory(venue), let url = NSURL(string: "\(category.icon.prefix)\(FIcon.FIconSize.S32.description)\(category.icon.suffix)"), let name = url.lastPathComponent, let pathComponents = url.pathComponents {
            let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
            categoryImageName = "\(prefix_image_name)_\(name)"
            
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
    
    private static func getBestCategory(venue:FVenue) -> FCategory? {
        for nextCat in venue.categories {
            if let url = NSURL(string: "\(nextCat.icon.prefix)\(FIcon.FIconSize.S32.description)\(nextCat.icon.suffix)"), let name = url.lastPathComponent, let pathComponents = url.pathComponents {
                let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
                let imageName = "\(prefix_image_name)_\(name)"
                if let image = ImageCache.sharedInstance().imageWithIdentifier(imageName) {
                    return nextCat
                }
            }
        }
        return venue.categories.first
    }
}

func ==(lhs: FoursquareLocationMapAnnotation, rhs:FoursquareLocationMapAnnotation) -> Bool {
    return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
}
