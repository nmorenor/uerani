//
//  RefreshMapAnnotationOperation.swift
//  uerani
//
//  Created by nacho on 7/14/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit
import FBAnnotationClustering
import RealmSwift

func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime,  dispatch_get_main_queue()) {
        completion()
    }
}

class RefreshMapAnnotationOperation: NSOperation {
   
    weak var mapView:MKMapView!
    private var semaphore = dispatch_semaphore_create(0)
    private var removeOperation = false
    private var requestProcessor:MapLocationRequestProcessor
    private var startedProgress = false
    
    init(mapView:MKMapView, requestProcessor:MapLocationRequestProcessor) {
        self.mapView = mapView
        self.requestProcessor = requestProcessor
        super.init()
        
        // we can be adding an excesive amount of refresh workers to the queue
        //this could lead to undesired results, only allow three on the queue
        if LocationRequestManager.sharedInstance().refreshOperationQueue.operationCount < 3 {
            LocationRequestManager.sharedInstance().refreshOperationQueue.addOperation(self)
        }
    }
    
    convenience init(mapView:MKMapView, removeAnnotations:Bool, requestProcessor:MapLocationRequestProcessor) {
        self.init(mapView: mapView, requestProcessor:requestProcessor)
        self.removeOperation = removeAnnotations
    }
    
    override func main() {
        if requestProcessor.searchBox == nil {
            return
        }
        if self.removeOperation {
            if let mapView = self.mapView {
                self.removeAnnotations(mapView)
            }
            
        } else {
            if let mapView = self.mapView {
                
                if let annotations = self.getAnnotations(), let mapView = self.mapView {
                    self.displayAnnotations(annotations, mapView: mapView)
                }
            }
        }
    }
    
    private func removeAnnotations(mapView:MKMapView) {
        if let mapAnnotations = mapView.annotations {
            if requestProcessor.shouldUseCluster() {
                self.displayNoAnnotations()
            } else {
                // on remove and with big zoom we do not want to remove visible operations
                if let visibleAnnotations = self.getNonClusteredAnnotations() {
                    self.displayAnnotations(visibleAnnotations, mapView: mapView)
                } else {
                    self.displayNoAnnotations()
                }
            }
        }
    }
    
    private func displayNoAnnotations() {
        self.displayAnnotations(Array<NSObject>(), mapView: mapView)
    }
    
    private func displayAnnotations(annotations:Array<NSObject>, mapView:MKMapView) {
        if let mapAnnotations = mapView.annotations {
            var before:NSMutableSet = NSMutableSet(array: mapAnnotations)
            before.removeObject(mapView.userLocation)
            if let calloutAnnotation = requestProcessor.calloutAnnotation {
                before.removeObject(calloutAnnotation)
            }
            
            var after:NSSet = NSSet(array: annotations)
            
            var toKeep:NSMutableSet = NSMutableSet(set: before)
            toKeep.intersectSet(after as Set<NSObject>)
            
            var toAdd = NSMutableSet(set: after)
            toAdd.minusSet(toKeep as Set<NSObject>)
            
            var toRemove = NSMutableSet(set: before)
            toRemove.minusSet(after as Set<NSObject>)
            
            if toAdd.count > 0 || toRemove.count > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    mapView.addAnnotations(toAdd.allObjects)
                    mapView.removeAnnotations(toRemove.allObjects)
                    //once ui is updated unlock, let other threads to execute
                    self.unlock()
                }
                //block thread, only one at a time will update the ui
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                if !self.requestProcessor.hasRunningSearch() {
                    let searchBeginNotification = NSNotification(name: "searchEnd", object: nil)
                    NSNotificationCenter.defaultCenter().postNotification(searchBeginNotification)
                }
            }
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    private func getAnnotations() -> Array<NSObject>? {
        if requestProcessor.shouldUseCluster() {
            return self.getClusteredAnnotations()
        } else {
            return self.getNonClusteredAnnotations()
        }
    }
    
    func getClusteredAnnotations() -> Array<NSObject>? {
        let scale:Double = Double(mapView.bounds.size.width) / Double(mapView.visibleMapRect.size.width)
        objc_sync_enter(requestProcessor.clusteringManager)
        let annotations = requestProcessor.clusteringManager.clusteredAnnotationsWithinMapRect(mapView.visibleMapRect, withZoomScale: scale) as! Array<NSObject>
        objc_sync_exit(requestProcessor.clusteringManager)
        return annotations
    }
    
    func getNonClusteredAnnotations() -> Array<NSObject>? {
        if let searchBox = requestProcessor.searchBox {
            let searchBeginNotification = NSNotification(name: "searchBegin", object: nil)
            NSNotificationCenter.defaultCenter().postNotification(searchBeginNotification)
            let predicate = searchBox.getPredicate(mapView.region, categoryFilter: self.requestProcessor.categoryFilter)
            let realm = Realm(path: Realm.defaultPath)
            let venues = realm.objects(FVenue).filter(predicate)
            var annotations = [FoursquareLocationMapAnnotation]()
            for venue in venues {
                annotations.append(FoursquareLocationMapAnnotation(venue: venue))
            }
            
            return annotations
        }
        return nil
    }
}
