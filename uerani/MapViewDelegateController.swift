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
        println("Hello world")
    }
}