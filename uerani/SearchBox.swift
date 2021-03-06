//
//  SearchBox.swift
//  uerani
//
//  Created by nacho on 7/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit
import RealmSwift

struct SearchBox {
    
    static let locationPredicate:String = "(%f <= location.lng) AND (location.lng <= %f) AND (%f <= location.lat) AND (location.lat <= %f)"
    static let internalBoxDistance:Double = VenueLocationSearchMediator.locationSearchDistance/4
    var center:GeoLocation
    var useCenter:Bool
    var boxDistance:Double
    
    var northWestBoundBox:GeoLocation.GeoLocationBoundBox
    var northBoundBox:GeoLocation.GeoLocationBoundBox
    var northEastBoundBox:GeoLocation.GeoLocationBoundBox
    var centralBoundBox:GeoLocation.GeoLocationBoundBox
    var westBoundBox:GeoLocation.GeoLocationBoundBox
    var eastBoundBox:GeoLocation.GeoLocationBoundBox
    var southWestBoundBox:GeoLocation.GeoLocationBoundBox
    var southBoundBox:GeoLocation.GeoLocationBoundBox
    var southEastBox:GeoLocation.GeoLocationBoundBox
    var triggeredNetworkSearch = false;
    var debug = false
    var searchMediator:VenueLocationSearchMediator
    weak var mapView:MKMapView?
    
    
    var neCoord:CLLocationCoordinate2D {
        get {
            return self.northEastBoundBox.neLocation.coordinate
        }
    }
    
    var swCoord:CLLocationCoordinate2D {
        get {
            return self.southWestBoundBox.swLocation.coordinate
        }
    }
    
    init(center:GeoLocation, distance:Double, mapView:MKMapView?, useCenter:Bool, searchMediator:VenueLocationSearchMediator) {
        if let mapView = mapView {
            self.mapView = mapView
        }
        self.useCenter = useCenter
        self.searchMediator = searchMediator
        self.center = center
        self.boxDistance = distance
        self.centralBoundBox = self.center.boundingBoxWithDistance(distance/2)
        self.northWestBoundBox = SearchBox.getNorthWestBox(centralBoundBox, distance: distance)
        self.northBoundBox = SearchBox.getNorthBox(centralBoundBox, distance: distance)
        self.northEastBoundBox = SearchBox.getNorthEastBox(centralBoundBox, distance: distance)
        self.westBoundBox = SearchBox.getWestBox(centralBoundBox, distance: distance)
        self.eastBoundBox = SearchBox.getEastBox(northEastBoundBox, distance: distance)
        self.southWestBoundBox = SearchBox.getSouthWestBox(centralBoundBox, distance: distance)
        self.southBoundBox = SearchBox.getSouthBox(centralBoundBox, distance: distance)
        self.southEastBox = SearchBox.getSouthEastBox(centralBoundBox, distance: distance)
        self.triggerFoursquareSearch()
        if let mapView = mapView where debug {
            self.showAsOverlay(mapView)
        }
        self.triggerForusquareSearchOperations()
    }
    
    func getPredicate() -> NSPredicate {
        return NSPredicate(format: SearchBox.locationPredicate, swCoord.longitude, neCoord.longitude, swCoord.latitude, neCoord.latitude)
    }
    
    private func getPredicate(box:GeoLocation.GeoLocationBoundBox) -> NSPredicate {
        return NSPredicate(format: SearchBox.locationPredicate, box.swLocation.coordinate.longitude, box.neLocation.coordinate.longitude, box.swLocation.coordinate.latitude, box.neLocation.coordinate.latitude)
    }
    
    static func getPredicate(sw:CLLocationCoordinate2D, ne:CLLocationCoordinate2D) -> NSPredicate {
        return NSPredicate(format: SearchBox.locationPredicate, sw.longitude, ne.longitude, sw.latitude, ne.latitude)

    }
    
    func getPredicate(region:MKCoordinateRegion) -> NSPredicate {
        return self.getPredicate(GeoLocation.boundingBox(region))
    }
    
    func showAsOverlay(mapView:MKMapView) {
        if self.boxDistance == VenueLocationSearchMediator.locationSearchDistance && self.debug {
            let locationsForOverlay = self.filterOverlayBoxes()
            if let locations = locationsForOverlay {
                dispatch_async(dispatch_get_main_queue()) {
                    for next in locations {
                        mapView.addOverlay(SearchBox.getPolygon(next))
                    }
                }
            }
        }
    }
    
    private func filterOverlayBoxes() -> Array<GeoLocation.GeoLocationBoundBox>? {
        if self.boxDistance == VenueLocationSearchMediator.locationSearchDistance {
            return searchMediator.getGidBoxLocations()
        }
        return nil
    }
    
    private func getLocations() -> Array<GeoLocation.GeoLocationBoundBox> {
        return [self.northWestBoundBox, self.northBoundBox, self.northEastBoundBox, self.westBoundBox, self.centralBoundBox, self.eastBoundBox, self.southWestBoundBox, self.southBoundBox, self.self.southEastBox]
    }
    
    func removeOverlays() {
        if let mapView = self.mapView where debug {
            dispatch_async(dispatch_get_main_queue()) {
                mapView.removeOverlays(mapView.overlays)
            }
        }
    }
    
    mutating func triggerFoursquareSearch() {
        if (self.triggeredNetworkSearch) {
            return
        }
        if self.boxDistance == SearchBox.internalBoxDistance {
            
            if self.boxDistance == SearchBox.internalBoxDistance {
                
                //only trigger forsquare search one per bounding box
                let locations = self.getLocations().filter({ !self.searchMediator.isInGridBox($0) })
                
                for location in locations {
                    self.searchMediator.addToGridBox(location)
                }
            }
            
        } else {
            let locations = self.getLocations()
            for location in locations {
                self.doSearch(location)
            }
        }
        self.triggeredNetworkSearch = true
    }
    
    func getSize() -> Double {
        return self.northEastBoundBox.neLocation.distanceTo(self.northWestBoundBox.nwLocation)
    }
    
    private func doSearch(location:GeoLocation.GeoLocationBoundBox) {
        var box = SearchBox(center: location.center, distance: self.boxDistance/2, mapView:self.mapView, useCenter:self.useCenter, searchMediator:self.searchMediator)
        box.triggerFoursquareSearch()
    }
    
    private func triggerForusquareSearchOperations() {
        if self.boxDistance == VenueLocationSearchMediator.locationSearchDistance {
            
            var locations = searchMediator.getGidBoxLocations()
            let regionCenter = GeoLocation(coordinate: mapView!.region.center)
            locations.sortInPlace() { lhs, rhs in
                if self.useCenter {
                    return lhs.center.distanceTo(self.center) < rhs.center.distanceTo(self.center)
                } else {
                    return lhs.center.distanceTo(regionCenter) < rhs.center.distanceTo(regionCenter)
                }
            }
            for location in locations {
                let _ = FoursquareLocationOperation(sw: location.swLocation.coordinate, ne: location.neLocation.coordinate, searchMediator:self.searchMediator)
            }
        }
    }
    
    static func getNorthWestBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.nwLocation.boundingBoxWithDistance(distance/2).nwLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getNorthBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.nwLocation.boundingBoxWithDistance(distance/2).neLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getNorthEastBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.neLocation.boundingBoxWithDistance(distance/2).neLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getWestBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.swLocation.boundingBoxWithDistance(distance/2).nwLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getEastBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.swLocation.boundingBoxWithDistance(distance/2).seLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getSouthWestBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.swLocation.boundingBoxWithDistance(distance/2).swLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getSouthBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.swLocation.boundingBoxWithDistance(distance/2).seLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getSouthEastBox(location:GeoLocation.GeoLocationBoundBox, distance:Double) -> GeoLocation.GeoLocationBoundBox {
        return location.seLocation.boundingBoxWithDistance(distance/2).seLocation.boundingBoxWithDistance(distance/2)
    }
    
    static func getPolygon(location:GeoLocation.GeoLocationBoundBox) -> MKPolygon {
        var points = [location.nwLocation.coordinate, location.swLocation.coordinate, location.seLocation.coordinate, location.neLocation.coordinate]
        return MKPolygon(coordinates: &points, count: 4)
    }
}
