//
//  FVenueMapAnnotation.swift
//  uerani
//
//  Created by nacho on 9/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

public class FVenueMapAnnotation : Object {
    
    public dynamic var title:String = ""
    public dynamic var subtitle:String = ""
    public dynamic var lat:Double = 0.0
    public dynamic var lng:Double = 0.0
    public dynamic var categoryImageName:String = ""
    public dynamic var categoryImageName8:String = ""
    public dynamic var categoryImageName12:String = ""
    public dynamic var categoryImageName64:String = ""
    public dynamic var categoryPrefix:String = ""
    public dynamic var categorySuffix:String = ""
    public dynamic var venueId:String = ""
    public dynamic var city:String = ""
    public dynamic var state:String = ""
    
    public var coordinate:CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        }
        
        set (coordinate) {
            self.lat = coordinate.latitude
            self.lng = coordinate.longitude
        }
    }
    
    public static override func primaryKey() -> String? {
        return "venueId"
    }
    
    public override class func ignoredProperties() -> [String] {
        return ["coordinate"]
    }
    
    static func loadData(annotation:FoursquareLocationMapAnnotation) -> FVenueMapAnnotation{
        var result = FVenueMapAnnotation()
        result.title = annotation.title
        result.subtitle = annotation.subtitle
        result.venueId = annotation.venueId
        result.coordinate = annotation.coordinate
        result.city = annotation.city
        result.state = annotation.state
        
        if let categoryImageName = annotation.categoryImageName {
            result.categoryImageName = categoryImageName
        }
        if let categoryImageName8 = annotation.categoryImageName8 {
            result.categoryImageName8 = categoryImageName8
        }
        if let categoryImageName12 = annotation.categoryImageName12 {
            result.categoryImageName12 = categoryImageName12
        }
        if let categoryImageName64 = annotation.categoryImageName64 {
            result.categoryImageName64 = categoryImageName64
        }
        if let categorySuffix = annotation.categorySuffix {
            result.categorySuffix = categorySuffix
        }
        if let categoryPrefix = annotation.categoryPrefix {
            result.categoryPrefix = categoryPrefix
        }
        return result
    }
}
