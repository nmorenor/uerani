//
//  GeoLocation.swift
//  grabbed
//  reference: http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates
//
//  Created by nacho on 7/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit

struct GeoLocation {
    
    struct GeoLocationBoundBox: Hashable, Equatable {
        var center:GeoLocation
        var distance:Double
        var neLocation:GeoLocation
        var swLocation:GeoLocation
        var nwLocation:GeoLocation
        var seLocation:GeoLocation
        
        var hashValue:Int {
            get {
                let prime:Int = 31
                var result:Int = 1
                var toHash = NSString(format: "[%.8f,%.8f]", center.coordinate.latitude, center.coordinate.longitude)
                result = prime * result + toHash.hashValue
                return result
            }
        }
        
        func containsLocation(location:GeoLocation) -> Bool {
            return (self.swLocation.coordinate.longitude <= location.longitude) && (location.longitude <= self.neLocation.longitude) && (self.swLocation.latitude <= location.latitude) && (location.latitude <= self.neLocation.coordinate.latitude)
        }
    }
    
    static let MIN_LAT:Double = -(M_PI_2)
    static let MAX_LAT:Double = M_PI_2
    static let MIN_LON:Double = -(M_PI)
    static let MAX_LON:Double = M_PI
    static let EARTH_RADIUS:Double = 6372797.6
    
    var radLat:Double
    var radLon:Double
    
    var coordinate:CLLocationCoordinate2D
    
    var latitude:Double {
        get {
            return self.coordinate.latitude
        }
    }
    
    var longitude:Double {
        get {
            return self.coordinate.longitude
        }
    }
    
    init(coordinate:CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.radLat = GeoLocation.toRadian(coordinate.latitude)
        self.radLon = GeoLocation.toRadian(coordinate.longitude)
    }
    
    func distanceTo(location:GeoLocation) -> Double {
        return acos(sin(self.radLat) * sin(location.radLat) +
            cos(radLat) * cos(location.radLat) *
            cos(radLon - location.radLon)) * GeoLocation.EARTH_RADIUS
    }
    
    /**
    * Get a bounding box for this location with a given dinstance in meters
    */
    func boundingBoxWithDistance(distance:Double) -> GeoLocationBoundBox {
        let radDist = distance/GeoLocation.EARTH_RADIUS
        var minLon = 0.0
        var maxLon = 0.0
        
        var minLat = radLat - radDist
        var maxLat = radLat + radDist
        
        if (minLat > GeoLocation.MIN_LAT && maxLat < GeoLocation.MAX_LAT) {
            let deltaLon = asin(sin(radDist) / cos(radLat))
            minLon = radLon - deltaLon;
            if (minLon < GeoLocation.MIN_LON) {
                minLon += 2.0 * M_PI
            }
            maxLon = radLon + deltaLon;
            if (maxLon > GeoLocation.MAX_LON) {
                maxLon -= 2.0 * M_PI
            }
        } else {
            minLat = max(minLat, GeoLocation.MIN_LAT)
            maxLat = min(maxLat, GeoLocation.MAX_LAT)
            minLon = -(M_PI)
            maxLon = M_PI
        }
        let neLocation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: GeoLocation.fromRadian(maxLat), longitude: GeoLocation.fromRadian(maxLon)))
        let swLocation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: GeoLocation.fromRadian(minLat), longitude: GeoLocation.fromRadian(minLon)))
        let nwLocation = GeoLocation(coordinate:CLLocationCoordinate2D(latitude: neLocation.latitude, longitude: swLocation.longitude))
        let seLocation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: swLocation.latitude, longitude: neLocation.longitude))
        let center = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: swLocation.latitude + ((neLocation.latitude - swLocation.latitude)/2), longitude: swLocation.longitude + ((neLocation.longitude - swLocation.longitude)/2)))
        return GeoLocationBoundBox(center: center, distance: distance, neLocation: neLocation, swLocation: swLocation, nwLocation:nwLocation, seLocation:seLocation)
    }
    
    static func boundingBox(searchRegion:MKCoordinateRegion) -> GeoLocationBoundBox {
        let minLat = searchRegion.center.latitude - (searchRegion.span.latitudeDelta / 2.0)
        let maxLat = searchRegion.center.latitude + (searchRegion.span.latitudeDelta / 2.0)
        
        let minLong = searchRegion.center.longitude - (searchRegion.span.longitudeDelta / 2.0)
        let maxLong = searchRegion.center.longitude + (searchRegion.span.longitudeDelta / 2.0)
        
        //Then transform those point into lat,lng values
        let neCoord = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong)
        let swCoord = CLLocationCoordinate2D(latitude: minLat, longitude: minLong)
        
        let nwCoord = CLLocationCoordinate2D(latitude: neCoord.latitude, longitude: swCoord.longitude)
        let seCoord = CLLocationCoordinate2D(latitude: swCoord.latitude, longitude: neCoord.longitude)
        
        let center = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: swCoord.latitude + ((neCoord.latitude - swCoord.latitude)/2), longitude: swCoord.longitude + ((neCoord.longitude - swCoord.longitude)/2)))
        
        return GeoLocationBoundBox(center: center, distance: GeoLocation.getDistance(searchRegion), neLocation: GeoLocation(coordinate: neCoord), swLocation: GeoLocation(coordinate:swCoord), nwLocation:GeoLocation(coordinate:nwCoord), seLocation:GeoLocation(coordinate:seCoord))
    }
    
    static func getDistance(region:MKCoordinateRegion) -> CLLocationDistance {
        let newLocation:CLLocation = CLLocation(latitude: region.center.latitude+region.span.latitudeDelta, longitude: region.center.longitude)
        let centerLocation:CLLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        let distance:CLLocationDistance = centerLocation.distanceFromLocation(newLocation)
        return distance
    }
    
    static func toRadian(x:Double) -> Double {
        return x * (M_PI/180)
    }
    
    static func fromRadian(x:Double) -> Double {
        return x * (180/M_PI)
    }
}

func ==(lhs:GeoLocation.GeoLocationBoundBox, rhs:GeoLocation.GeoLocationBoundBox) ->Bool {
    return lhs.center.coordinate.latitude == rhs.center.coordinate.latitude && lhs.center.coordinate.longitude == rhs.center.coordinate.longitude
}
