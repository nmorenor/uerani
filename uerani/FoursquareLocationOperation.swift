//
//  FoursquareLocationOperation.swift
//  uerani
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
    private var searchMediator:VenueLocationSearchMediator
    private var center:GeoLocation
    private var semaphore = dispatch_semaphore_create(0)
    
    init(sw:CLLocationCoordinate2D, ne:CLLocationCoordinate2D, searchMediator:VenueLocationSearchMediator) {
        self.sw = sw
        self.ne = ne
        self.center = GeoLocation(coordinate: CLLocationCoordinate2D(latitude: sw.latitude + ((ne.latitude - sw.latitude)/2), longitude: sw.longitude + ((ne.longitude - sw.longitude)/2)))
        self.searchMediator = searchMediator
        super.init()
        self.searchMediator.addRunningSearch(self.center)
        LocationRequestManager.sharedInstance().operationQueue.addOperation(self)
    }
    
    public override func main() {
        var searchOnFoursquare = true
        if cancelled {
            return
        }
        let realm = try! Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        let shouldCallFoursquareAPI = self.shouldCallFoursquareAPI(realm)
        if !shouldCallFoursquareAPI {
            searchOnFoursquare = false
            self.doLocalCacheSearch(realm)
        }
        
        if searchOnFoursquare && shouldCallFoursquareAPI {
            doFoursquareSearch(self.searchHandler)
        }
        self.searchMediator.removeRunningSearch(self.center)
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
            let delta = (VenueLocationSearchMediator.locationSearchDistance/4) / 2
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
    
    //Search on local cache
    private func doLocalCacheSearch(realm:Realm) {
        let predicate = SearchBox.getPredicate(self.sw, ne: self.ne)
        let venueResults = realm.objects(FVenue).filter(predicate)
        var venues:AnyGenerator<FVenue>
        if let filter = self.searchMediator.getFilter() {
            venues = filter.filterVenues(anyGenerator(venueResults.generate()))
        } else {
            venues = anyGenerator(venueResults.generate())
        }
        
        var annotations = [FoursquareLocationMapAnnotation]()
        for nextVenue in venues {
            
            for nextCat in nextVenue.categories {
                var downloadCategoryImage = true
                if let imageid = getImageIdentifier(FIcon.FIconSize.S32.description, iconCapable: nextCat), let _ = ImageCache.sharedInstance().imageWithIdentifier(imageid) {
                    downloadCategoryImage = false
                }
                if downloadCategoryImage {
                    _ = FoursquareCategoryIconWorker(prefix: nextCat.icon!.prefix, suffix: nextCat.icon!.suffix)
                }
            }
            annotations.append(FoursquareLocationMapAnnotation(venue: nextVenue))
        }
        
        if cancelled {
            return
        }
        self.addAnnotationsToCluster(annotations, realm: realm)
        if cancelled {
            return
        }
        searchMediator.updateUI()
    }
    
    private func doFoursquareSearch(completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        if cancelled {
            return
        }
        FoursquareClient.sharedInstance().searchVenuesForLocationInBox(sw, ne: ne, completionHandler: completionHandler)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    private func searchHandler(success:Bool, result:[[String:AnyObject]]?, errorString:String?) {
        let realm = try! Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        if let _ = errorString {
            //when we have any kind of error searching on foursquare we will just try to look on local cache
            self.doLocalCacheSearch(realm)
        } else {
            if let result = result where result.count > 0 {
                let newVenues:Queue = Queue<FVenue>()
                let center = self.getCenter()
                let boxCenter = SearchBoxCenter()
                boxCenter.lat = center.latitude
                boxCenter.lng = center.longitude
                try! realm.write() {
                    realm.add(boxCenter, update: true)
                    for next in result {
                        let venue = realm.create(FVenue.self, value: next, update: true)
                        newVenues.enqueue(venue)
                    }
                }
                
                var annotations:[FoursquareLocationMapAnnotation] = [FoursquareLocationMapAnnotation]()
                var venues:AnyGenerator<FVenue>
                if let filter = self.searchMediator.getFilter() {
                    venues = filter.filterVenues(anyGenerator(newVenues.generate()))
                } else {
                    venues = anyGenerator(newVenues.generate())
                }
                
                for venue in venues {
                    for nextCategory in venue.categories {
                        _ = FoursquareCategoryIconWorker(prefix: nextCategory.icon!.prefix, suffix: nextCategory.icon!.suffix)

                    }
                    annotations.append(FoursquareLocationMapAnnotation(venue: venue))
                }
            
                if cancelled {
                    return
                }
                //filter with category predicate
            
                self.addAnnotationsToCluster(annotations, realm: realm)
                if cancelled {
                    return
                }
                
                searchMediator.updateUI()
                
                
            } else {
                let center = self.getCenter()
                let boxCenter = SearchBoxCenter()
                boxCenter.lat = center.latitude
                boxCenter.lng = center.longitude
                try! realm.write() {
                    realm.add(boxCenter, update: true)
                }
            }
        }
        if !cancelled {
            self.unlock()
        }
    }
    
    private func addAnnotationsToCluster(annotations:Array<FoursquareLocationMapAnnotation>, realm:Realm) {
       
        objc_sync_enter(searchMediator.clusteringManager)
        //avoid any possible thread lock in here
        if cancelled {
            objc_sync_exit(searchMediator.clusteringManager)
            return
        }
        if cancelled {
            objc_sync_exit(searchMediator.clusteringManager)
            return
        }
        searchMediator.addCurrentVenues(annotations, realm: realm)
        if cancelled {
            objc_sync_exit(searchMediator.clusteringManager)
            return
        }
        let results = realm.objects(FVenueMapAnnotation.self)
        var allAnnotations = [FoursquareLocationMapAnnotation]()
        for next in results {
            allAnnotations.append(FoursquareLocationMapAnnotation(venueAnnotation: next))
        }
        searchMediator.clusteringManager.setAnnotations(allAnnotations)
        objc_sync_exit(searchMediator.clusteringManager)
    }
}