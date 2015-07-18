//
//  FoursquareLocationOperation.swift
//  grabbed
//
//  Created by nacho on 6/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift
import FBAnnotationClustering

public class FoursquareLocationOperation: NSOperation {
    
    var sw:CLLocationCoordinate2D
    var ne:CLLocationCoordinate2D
    private var semaphore = dispatch_semaphore_create(0)
    
    init(sw:CLLocationCoordinate2D, ne:CLLocationCoordinate2D) {
        self.sw = sw
        self.ne = ne
        super.init()
        
        LocationRequestManager.sharedInstance().operationQueue.addOperation(self)
    }
    
    public override func main() {
        let requestProcessor = LocationRequestManager.sharedInstance().requestProcessor
        var searchOnFoursquare = true
        let realm = Realm(path: Realm.defaultPath)
        let shouldCallFoursquareAPI = self.shouldCallFoursquareAPI(realm)
        if !shouldCallFoursquareAPI {
            let predicate = SearchBox.getPredicate(self.sw, ne: self.ne)
            let venues = realm.objects(FVenue).filter(predicate)
            
            searchOnFoursquare = false
            var annotations = [FoursquareLocationMapAnnotation]()
            for venue in venues {
                annotations.append(FoursquareLocationMapAnnotation(venue: venue))
            }
                
            if cancelled {
                return
            }
            self.addAnnotationsToCluster(annotations)
            if cancelled {
                return
            }
            requestProcessor.updateUI()
        }
        
        if searchOnFoursquare && shouldCallFoursquareAPI {
            doFoursquareSearch(self.searchHandler)
        }
    }
    
    /**
    * This will look on the DB for any center location tha we have previously searched
    * If we already have searched this bounding box, check if the distance between the center is more than half of
    * the radius of the gridBox
    */
    func shouldCallFoursquareAPI(realm:Realm) -> Bool {
        let matchingCenters = realm.objects(SearchBoxCenter).filter(getSearchBoxPredicate())
        if matchingCenters.count > 0 {
            let center = getCenter()
            let delta = (MapLocationRequestProcessor.locationSearchDistance/4) / 2
            let currentCenterLocation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude))
            var result = true
            for nextCenter in matchingCenters {
                let nextCenterLocation = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: nextCenter.lat, longitude: nextCenter.lng))
                let distanceBetweenCenters = currentCenterLocation.distanceTo(nextCenterLocation)
                if  distanceBetweenCenters <= delta {
                    result = false
                    break
                }
            }
            return result
        }
        return true
    }
    
    // Predicate for SearchBoxCenter, with the coordinates of this bounding box
    func getSearchBoxPredicate() -> NSPredicate {
        return NSPredicate(format: "(%f <= lng) AND (lng <= %f) AND (%f <= lat) AND (lat <= %f)", sw.longitude, ne.longitude, sw.latitude, ne.latitude)
    }
    
    func getCenter() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: sw.latitude + ((ne.latitude - sw.latitude)/2), longitude: sw.longitude + ((ne.longitude - sw.longitude)/2))
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    override public func cancel() {
        self.unlock()
        super.cancel()
    }
    
    private func doFoursquareSearch(completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        if cancelled {
            return
        }
        FoursquareClient.sharedInstance().searchVenuesForLocationInBox(sw, ne: ne, completionHandler: completionHandler)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    private func searchHandler(success:Bool, result:[[String:AnyObject]]?, errorString:String?) {
        if let error = errorString {
            println(error)
        } else {
            if let result = result where result.count > 0 {
                let realm = Realm(path: Realm.defaultPath)
                var newVenues:[FVenue]? = nil
                
                let center = self.getCenter()
                let boxCenter = SearchBoxCenter()
                boxCenter.lat = center.latitude
                boxCenter.lng = center.longitude
                realm.write() {
                    realm.add(boxCenter, update: true)
                    newVenues = result.map({realm.create(FVenue.self, value: $0, update: true)})
                }
                if let venues = newVenues {
                    let annotations = venues.map({FoursquareLocationMapAnnotation(venue: $0)})
                    
                    if cancelled {
                        return
                    }
                    self.addAnnotationsToCluster(annotations)
                    if cancelled {
                        return
                    }
                    LocationRequestManager.sharedInstance().requestProcessor.updateUI()
                    
                }
            } else {
                let realm = Realm(path: Realm.defaultPath)
                let center = self.getCenter()
                let boxCenter = SearchBoxCenter()
                boxCenter.lat = center.latitude
                boxCenter.lng = center.longitude
                realm.write() {
                    realm.add(boxCenter, update: true)
                }
            }
        }
        if !cancelled {
            self.unlock()
        }
    }
    
    private func addAnnotationsToCluster(annotations:Array<FoursquareLocationMapAnnotation>) {
        let requestProcessor = LocationRequestManager.sharedInstance().requestProcessor
        objc_sync_enter(requestProcessor.clusteringManager)
        //avoid any possible thread lock in here
        if cancelled {
            objc_sync_exit(requestProcessor.clusteringManager)
            return
        }
        let currentAnotations:[FoursquareLocationMapAnnotation] = requestProcessor.clusteringManager.allAnnotations().map({return $0 as! FoursquareLocationMapAnnotation})
        if cancelled {
            return
        }
        var annotationSet:Set<FoursquareLocationMapAnnotation> = Set(currentAnotations)
        if cancelled {
            objc_sync_exit(requestProcessor.clusteringManager)
            return
        }
        annotationSet.unionInPlace(annotations)
        if cancelled {
            objc_sync_exit(requestProcessor.clusteringManager)
            return
        }
        requestProcessor.clusteringManager.setAnnotations(Array(annotationSet))
        objc_sync_exit(requestProcessor.clusteringManager)
    }
}