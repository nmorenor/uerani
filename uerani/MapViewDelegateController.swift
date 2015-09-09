//
//  MapViewDelegateController.swift
//  uerani
//
//  Created by nacho on 8/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit
import FBAnnotationClustering

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let calloutAnnotation = self.searchMediator.calloutAnnotation {
            mapView.removeAnnotation(calloutAnnotation)
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let clusterAnnotation = view.annotation as? FBAnnotationCluster {
            return
        }
        if let userAnnotation = view.annotation as? MKUserLocation {
            return
        }
        
        let searchMediator = self.searchMediator
        
        searchMediator.calloutAnnotation = CalloutAnnotation(coordinate: view.annotation.coordinate)
        self.selectedMapAnnotationView = view
        mapView.addAnnotation(searchMediator.calloutAnnotation!)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let userAnnotation = annotation as? MKUserLocation {
            return nil
        }
        
        var view:MKAnnotationView?
        if let cluserAnnotation = annotation as? FBAnnotationCluster {
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(clusterPin) as? ClusteredPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = ClusteredPinAnnotationView(annotation: annotation, reuseIdentifier: clusterPin)
            }
        } else if let foursquareAnnotation = annotation as? FoursquareLocationMapAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? CategoryPinAnnotationView {
                dequeuedView.annotation = annotation
                dequeuedView.configure(foursquareAnnotation)
                view = dequeuedView
            } else {
                var annotationView = CategoryPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.configure(foursquareAnnotation)
                view = annotationView
            }
        } else {
            var customView:FoursquareVenueDetailsAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(calloutPin) as? FoursquareVenueDetailsAnnotationView {
                customView = dequeuedView
            } else {
                customView = FoursquareVenueDetailsAnnotationView(annotation: annotation, reuseIdentifier: calloutPin)
            }
            customView.configure(self.mapView, selectedAnnotationView: self.selectedMapAnnotationView, annotation: annotation)
            
            view = customView
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if self.isRefreshReady {
            NSOperationQueue().addOperationWithBlock({
                if self.searchMediator.shouldCalculateSearchBox() {
                    self.searchMediator.triggerLocationSearch(mapView.region, useLocation:true)
                }
            })
            RefreshMapAnnotationOperation(mapView: mapView, searchMediator: self.searchMediator)
        }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        if fullyRendered && self.isRefreshReady {
            self.searchMediator.triggerLocationSearch(mapView.region, useLocation:true)
        }
    }
    
    //this is used in case of debug
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let overlay = overlay as? MKPolygon {
            var renderer = MKPolygonRenderer(polygon: overlay)
            renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            renderer.lineWidth = 1
            return renderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? FoursquareLocationMapAnnotation {
            
            var image = ImageCache.sharedInstance().imageWithIdentifier("venue_map_\(annotation.venueId)")
            if let image = image {
                self.displayVenueDetailViewController(annotation)
            } else {
                var snapshotter = self.getSnapshotter(annotation)
                snapshotter.startWithQueue(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { snapshot, error in
                    self.generateVenueMapImageAndDisplayDetails(annotation, snapshot: snapshot, error: error)
                }
            }
            
            println("\(annotation.venueId)")
        }
    }
    
    private func getSnapshotter(annotation:FoursquareLocationMapAnnotation) -> MKMapSnapshotter {
        var options = MKMapSnapshotOptions()
        var rect = CGRectMake(0, 0, (self.view.frame.size.width - 40) / 2, self.view.frame.size.height * 0.20)
        options.size = rect.size
        options.scale = UIScreen.mainScreen().scale
        options.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500.0, 500.0)
        
        return MKMapSnapshotter(options: options)
    }
    
    private func generateVenueMapImageAndDisplayDetails(annotation:FoursquareLocationMapAnnotation, snapshot:MKMapSnapshot, error:NSError?) {
        if let error = error {
            println("Error taking map snapshot image")
        } else {
            var image = snapshot.image
            var annotationView = CategoryPinAnnotationView(annotation: annotation, reuseIdentifier: self.identifier)
            annotationView.configure(annotation)
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(annotationView.image.size.width + 5, annotationView.image.size.height + 10), false, image.scale)
            var context:CGContextRef = UIGraphicsGetCurrentContext()
            annotationView.drawInContext(context)
            var annotationImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.drawAtPoint(CGPointMake(0, 0))
            
            var point = snapshot.pointForCoordinate(annotation.coordinate)
            var pinCenterOffset = annotationView.centerOffset;
            point.x -= annotationImage.size.width / 2;
            point.y -= annotationImage.size.height / 2;
            //extract the triangle height
            point.y -= 13
            point.x += pinCenterOffset.x;
            point.y += pinCenterOffset.y;
            
            annotationImage.drawAtPoint(point)
            var finalImage = UIGraphicsGetImageFromCurrentImageContext()
            
            ImageCache.sharedInstance().storeImage(finalImage, withIdentifier: "venue_map_\(annotation.venueId)")
            
            UIGraphicsEndImageContext()
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.displayVenueDetailViewController(annotation)
        }
    }
    
    private func displayVenueDetailViewController(annotation:FoursquareLocationMapAnnotation) {
        var detailsController = self.storyboard?.instantiateViewControllerWithIdentifier("RealmDetailsViewController") as! RealmVenueDetailViewController
        detailsController.venueId = annotation.venueId
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
}