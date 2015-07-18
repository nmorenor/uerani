//
//  RefreshMapAnnotationOperation.swift
//  grabbed
//
//  Created by nacho on 7/14/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit
import FBAnnotationClustering
import RealmSwift

class RefreshMapAnnotationOperation: NSOperation {
   
    weak var mapView:MKMapView!
    private var semaphore = dispatch_semaphore_create(0)
    private var removeAllAnnotations = false
    
    init(mapView:MKMapView) {
        self.mapView = mapView
        super.init()
        
        LocationRequestManager.sharedInstance().refreshOperationQueue.addOperation(self)
    }
    
    convenience init(mapView:MKMapView, removeAnnotations:Bool) {
        self.init(mapView: mapView)
        self.removeAllAnnotations = removeAnnotations
    }
    
    override func main() {
        if self.removeAllAnnotations {
            if let mapView = self.mapView {
                self.removeAnnotations(mapView)
            }
            
        } else {
            if let mapView = self.mapView {
                let requestProcessor = LocationRequestManager.sharedInstance().requestProcessor
                if let annotations = self.getAnnotations(), let mapView = self.mapView {
                    self.displayAnnotations(annotations, mapView: mapView)
                }
            }
        }
    }
    
    private func removeAnnotations(mapView:MKMapView) {
        if let mapAnnotations = mapView.annotations {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                mapView.removeAnnotations(mapAnnotations)
                //once ui is updated unlock, let other threads to execute
                self.unlock()
            }
            //block thread, only one at a time will update the ui
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        }
    }
    
    private func displayAnnotations(annotations:Array<NSObject>, mapView:MKMapView) {
        if let mapAnnotations = mapView.annotations {
            var before:NSMutableSet = NSMutableSet(array: mapAnnotations)
            before.removeObject(mapView.userLocation)
            
            var after:NSSet = NSSet(array: annotations)
            
            var toKeep:NSMutableSet = NSMutableSet(set: before)
            toKeep.intersectSet(after as Set<NSObject>)
            
            var toAdd = NSMutableSet(set: after)
            toAdd.minusSet(toKeep as Set<NSObject>)
            
            var toRemove = NSMutableSet(set: before)
            toRemove.minusSet(after as Set<NSObject>)
            
            if toAdd.count > 0 || toRemove.count > 0 {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    mapView.addAnnotations(toAdd.allObjects)
                    mapView.removeAnnotations(toRemove.allObjects)
                    //once ui is updated unlock, let other threads to execute
                    self.unlock()
                }
                //block thread, only one at a time will update the ui
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            }
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    private func getAnnotations() -> Array<NSObject>? {
        let requestProcessor = LocationRequestManager.sharedInstance().requestProcessor
        if requestProcessor.shouldUseCluster() {
            let scale:Double = Double(mapView.bounds.size.width) / Double(mapView.visibleMapRect.size.width)
            let annotations = requestProcessor.clusteringManager.clusteredAnnotationsWithinMapRect(mapView.visibleMapRect, withZoomScale: scale) as! Array<NSObject>
            return annotations
        } else {
            if let searchBox = requestProcessor.searchBox {
                let predicate = searchBox.getPredicate(mapView.region)
                let realm = Realm(path: Realm.defaultPath)
                
                let venues = realm.objects(FVenue).filter(searchBox.getPredicate(mapView.region))
                var annotations = [FoursquareLocationMapAnnotation]()
                for venue in venues {
                    annotations.append(FoursquareLocationMapAnnotation(venue: venue))
                }
                
                return annotations
            }
        }
        return nil
    }
}
