//
//  MapLocationRequestProcessor.swift
//  grabbed
//
//  Created by nacho on 6/14/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift
import FBAnnotationClustering

public class MapLocationRequestProcessor {
    
    static let locationSearchDistance:Double = 1000.00
    
    weak var mapView:MKMapView?
    var authorized:Bool = false
    var location:CLLocation?
    var clusteringManager:FBClusteringManager = FBClusteringManager(annotations: [FoursquareLocationMapAnnotation]())
    var triggeredAuthorization:Bool = false
    var initialRegion:Bool = false
    var calloutAnnotation:CalloutAnnotation?
    var selectedMapAnnotationView:MKAnnotationView?
    var searchBox:SearchBox? {
        willSet {
            self.cleanGridBox()
            if let mapView = self.mapView {
                RefreshMapAnnotationOperation(mapView: mapView)
            }
        }
    }
    
    var mutex:NSObject = NSObject()
    
    //performance of NSSet is better than swift Set
    var gridBox:NSMutableSet = NSMutableSet()
    var allAnnotations:NSMutableSet = NSMutableSet()
    
    //Authorize get user location
    public func trigerAuthorization(authorized:Bool) {
        if !self.authorized && authorized {
            self.setAllowLocation()
        }
        self.triggeredAuthorization = true
        self.authorized = authorized
        if !self.authorized {
            self.initialRegion = true
        }
    }
    
    public func didUpdateLocation(newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if self.location == nil {
            self.displayLocation(newLocation)

        }
        self.location = newLocation
    }
    
    func setAllowLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView?.showsUserLocation = true
            self.mapView?.userLocation
        }
    }
    
    func displayLocation(location:CLLocation) {
        var region:MKCoordinateRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.055, longitudeDelta: 0.055))
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView?.setRegion(region, animated: true)
            self.triggerLocationSearch(region)
        }
    }
    
    func triggerLocationSearch(region:MKCoordinateRegion?) {
        NSOperationQueue().addOperationWithBlock({
            if self.triggeredAuthorization && self.shouldCalculateSearchBox() {
                LocationRequestManager.sharedInstance().operationQueue.cancelAllOperations()
                if let region = region {
                    self.calculateSearchBox(region)
                } else {
                    self.calculateSearchBox(self.mapView?.region)
                }
                self.initialRegion = true
            }
        })
    }
    
    func isRefreshReady() -> Bool {
        if let searchBox = self.searchBox {
            return self.triggeredAuthorization && self.initialRegion
        }
        return false
    }
    
    func calculateSearchBox(region:MKCoordinateRegion?) {
        if let mapView = mapView, let region = region {
            self.searchBox?.removeOverlays()
            let centralLocation = GeoLocation(coordinate: region.center)
            self.searchBox = SearchBox(center: centralLocation, distance: MapLocationRequestProcessor.locationSearchDistance, mapView:mapView)
        }
    }
    
    func updateUI() {
        mapView?.delegate.mapView!(mapView, regionDidChangeAnimated: true)
    }
    
    func shouldUseCluster() -> Bool {
        if let searchBox = self.searchBox, let mapView = self.mapView {
            let mapRegionDistance = GeoLocation.getDistance(mapView.region)
            return mapRegionDistance > MapLocationRequestProcessor.locationSearchDistance + 1
        }
        return true
    }
    
    func shouldCalculateSearchBox() -> Bool {
        if let searchBox = self.searchBox, let mapView = self.mapView {
            let mapRegionDistance = GeoLocation.getDistance(mapView.region)
            if mapRegionDistance > (MapLocationRequestProcessor.locationSearchDistance * 10) {
                return false
            }
            let centerLocation = GeoLocation(coordinate: mapView.region.center)
            let deltaDistance = centerLocation.distanceTo(searchBox.center)
            return deltaDistance > (searchBox.getSize()/2)
        }
        return true
    }
    
    func getGidBoxLocations() -> Array<GeoLocation.GeoLocationBoundBox> {
        var result:Array<GeoLocation.GeoLocationBoundBox>!
        objc_sync_enter(self.mutex)
        result = self.gridBox.allObjects as! Array<GeoLocation.GeoLocationBoundBox>
        println(result.count)
        objc_sync_exit(self.mutex)
        return result
    }
    
    func cleanGridBox() {
        objc_sync_enter(self.mutex)
        self.gridBox.removeAllObjects()
        objc_sync_exit(self.mutex)
    }
    
    func isInGridBox(location:GeoLocation.GeoLocationBoundBox) -> Bool {
        var result = false
        objc_sync_enter(self.mutex)
        self.isInGridBoxInternal(location)
        objc_sync_exit(self.mutex)
        return result
    }
    
    /**
    * The original idea for this was to use Set.contains, but seems that our Geolocation calculation of 
    * Bounding boxes does not match exactly the same center so the hashValue could be different
    * instead we look on the already added boxes to the search grid and test if the location center
    * is on any of the gridBox bounding boxes. This will reduce the number of threads looking for venues
    * meaning faster UI and less API requests
    *
    * Use it carefully, not thread safe, for thread safe use the non private funcions
    */
    private func isInGridBoxInternal(location:GeoLocation.GeoLocationBoundBox) -> Bool {
        for next in self.gridBox {
            if let nextLocation = next as? GeoLocation.GeoLocationBoundBox {
                let result = nextLocation.containsLocation(location.center)
                if result {
                    return true
                }
            }
        }
        return false
    }
    
    func addToGridBox(location:GeoLocation.GeoLocationBoundBox) {
        objc_sync_enter(self.mutex)
        if !self.isInGridBoxInternal(location) {
            self.gridBox.addObject(location)
        }
        objc_sync_exit(self.mutex)
    }
}
