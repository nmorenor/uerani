//
//  LocationRequestManager.swift
//  grabbed
//
//  Created by nacho on 6/14/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

public class LocationRequestManager: NSObject, CLLocationManagerDelegate {
    
    public var manager:CLLocationManager
    public var requestProcessor:MapLocationRequestProcessor
    public var location:CLLocation?
    var operationQueue:NSOperationQueue
    var refreshOperationQueue:NSOperationQueue
    
    public class func sharedInstance() -> LocationRequestManager {
        struct Singleton {
            static var instance = LocationRequestManager()
        }
        return Singleton.instance
    }
    
    public override init() {
        self.manager = CLLocationManager()
        self.manager.distanceFilter = kCLDistanceFilterNone
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.requestProcessor = MapLocationRequestProcessor()
        
        //setup operation queue
        operationQueue = NSOperationQueue()
        operationQueue.name = "Location operation Queue"
        operationQueue.maxConcurrentOperationCount = 5
        
        refreshOperationQueue = NSOperationQueue()
        refreshOperationQueue.name = "Refresh annotation operation"
        refreshOperationQueue.maxConcurrentOperationCount = 1
        
        super.init()
        self.manager.delegate = self
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.manager.startUpdatingLocation()
            self.requestProcessor.trigerAuthorization(true)
        } else {
            self.requestProcessor.trigerAuthorization(false)
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.location = newLocation
        requestProcessor.didUpdateLocation(newLocation, fromLocation: oldLocation)
    }
}