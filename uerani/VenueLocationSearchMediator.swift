//
//  VenueLocationSearchMediator.swift
//  uerani
//
//  Created by nacho on 6/14/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift
import FBAnnotationClustering

public class VenueLocationSearchMediator {
    
    static let locationSearchDistance:Double = 1000.00
    
    unowned var mapView:MKMapView
    var clusteringManager:FBClusteringManager = FBClusteringManager(annotations: [FoursquareLocationMapAnnotation]())
    var calloutAnnotation:CalloutAnnotation?
    
    var searchBox:SearchBox? {
        willSet {
            self.cleanGridBox()
            RefreshMapAnnotationOperation(mapView: mapView, searchMediator:self)
        }
    }
    
    init(mapView:MKMapView) {
        self.mapView = mapView
    }
    
    var mutex:NSObject = NSObject()
    
    //performance of NSSet is better than swift Set
    var gridBox:NSMutableSet = NSMutableSet()
    var allAnnotations:NSMutableSet = NSMutableSet()
    var runningSearchLocations:NSMutableSet = NSMutableSet()
    var categoryFilter:CategoryFilter? {
        didSet {
            objc_sync_enter(self.mutex)
            self.filter = nil
            objc_sync_exit(self.mutex)
        }
    }
    var filter:CategroyVenueFilter?
    
    func setAllowLocation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.showsUserLocation = true
            self.mapView.userLocation
        }
    }
    
    func displayLocation(location:CLLocation) {
        var region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 400.0, 40.0)
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    func triggerLocationSearch(region:MKCoordinateRegion?, useLocation:Bool) {
        NSOperationQueue().addOperationWithBlock({
            if self.shouldCalculateSearchBox() {
                LocationRequestManager.sharedInstance().operationQueue.cancelAllOperations()
                self.cleanRunningSearches()
                if let location = LocationRequestManager.sharedInstance().location where self.searchBox == nil && useLocation {
                    var region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 400.0, 400.0)
                    region.center = location.coordinate
                    self.calculateSearchBox(region, useCenter:true)
                } else {
                    if let region = region {
                        self.calculateSearchBox(region, useCenter:false)
                    } else {
                        self.calculateSearchBox(self.mapView.region, useCenter:false)
                    }
                }
            }
        })
    }
    
    func calculateSearchBox(region:MKCoordinateRegion?, useCenter:Bool) {
        if let region = region {
            self.searchBox?.removeOverlays()
            let centralLocation = GeoLocation(coordinate: region.center)
            
            self.searchBox = SearchBox(center: centralLocation, distance: VenueLocationSearchMediator.locationSearchDistance, mapView:mapView, useCenter:useCenter, searchMediator:self)
            
        }
    }
    
    func updateUI() {
        mapView.delegate.mapView!(mapView, regionDidChangeAnimated: true)
    }
    
    func shouldUseCluster() -> Bool {
        if let searchBox = self.searchBox {
            let mapRegionDistance = GeoLocation.getDistance(mapView.region)
            var maxDistanceForNonClustered = (VenueLocationSearchMediator.locationSearchDistance * 0.5) + 1
            return mapRegionDistance > maxDistanceForNonClustered
        }
        return true
    }
    
    func shouldCalculateSearchBox() -> Bool {
        if let searchBox = self.searchBox {
            let mapRegionDistance = GeoLocation.getDistance(mapView.region)
            if mapRegionDistance > ((VenueLocationSearchMediator.locationSearchDistance) * 10) {
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
    
    func doSearchWithCategory(filter:CategoryFilter?) {
        NSOperationQueue().addOperationWithBlock() {
            self.cleanMap()
            self.categoryFilter = filter
            self.getFilter()
            self.triggerLocationSearch(self.mapView.region, useLocation:false)
        }
    }
    
    func cleanMap() {
        self.searchBox = nil
        LocationRequestManager.sharedInstance().operationQueue.cancelAllOperations()
        LocationRequestManager.sharedInstance().refreshOperationQueue.cancelAllOperations()
        self.cleanRunningSearches()
        objc_sync_enter(self.clusteringManager)
        self.allAnnotations.removeAllObjects()
        self.clusteringManager = FBClusteringManager(annotations: [FoursquareLocationMapAnnotation]())
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        objc_sync_exit(self.clusteringManager)
    }
    
    func cleanRunningSearches() {
        objc_sync_enter(self.mutex)
        self.runningSearchLocations.removeAllObjects()
        objc_sync_exit(self.mutex)
    }
    
    func addRunningSearch(location:GeoLocation) {
        objc_sync_enter(self.mutex)
        let hash = self.calculateHashFor(location)
        var wasEmpty = self.runningSearchLocations.count == 0
        self.runningSearchLocations.addObject(hash)
        if wasEmpty {
            let searchBeginNotification = NSNotification(name: UERANI_MAP_BEGIN_PROGRESS, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(searchBeginNotification)
        }
        objc_sync_exit(self.mutex)
    }
    
    func hasRunningSearch() -> Bool {
        var empty = false
        objc_sync_enter(self.mutex)
        empty = self.runningSearchLocations.count != 0
        objc_sync_exit(self.mutex)
        return empty
    }
    
    func removeRunningSearch(location:GeoLocation) {
        objc_sync_enter(self.mutex)
        let hash = self.calculateHashFor(location)
        self.runningSearchLocations.removeObject(hash)
        objc_sync_exit(self.mutex)
    }
    
    func calculateHashFor(location:GeoLocation) -> Int {
        let prime:Int = 31
        var result:Int = 1
        var toHash = NSString(format: "[%.8f,%.8f]", location.coordinate.latitude, location.coordinate.longitude)
        result = prime * result + toHash.hashValue
        return result
    }
    
    func getFilter() -> CategroyVenueFilter? {
        var result:CategroyVenueFilter?
        objc_sync_enter(self.mutex)
        if let categoryFilter = self.categoryFilter where self.filter == nil {
            self.filter = CategroyVenueFilter(filter: categoryFilter)
        }
        result = self.filter
        objc_sync_exit(self.mutex)
        return result
    }
}
