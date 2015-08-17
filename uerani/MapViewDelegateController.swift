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
                view = dequeuedView
            } else {
                view = CategoryPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if let categoryImageName = foursquareAnnotation.categoryImageName {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                    if let image12 = ImageCache.sharedInstance().imageWithIdentifier(foursquareAnnotation.categoryImageName12) {
                        view!.image = image12
                    } else {
                        var image12 = CategoryPinAnnotationView.resizeImage(image, newSize:CGSizeMake(12, 12))
                        ImageCache.sharedInstance().storeImage(image12, withIdentifier: foursquareAnnotation.categoryImageName12!)
                        view!.image = image12
                    }
                } else if let prefix = foursquareAnnotation.categoryPrefix, let suffix = foursquareAnnotation.categorySuffix {
                    FoursquareCategoryIconWorker(prefix: prefix, suffix: suffix)
                    if let image = UIImage(named: defaultPinImage) {
                        view!.image = CategoryPinAnnotationView.resizeImage(image, newSize:CGSizeMake(12, 12))
                    }
                } else {
                    if let image = UIImage(named: defaultPinImage) {
                        view!.image = CategoryPinAnnotationView.resizeImage(image, newSize:CGSizeMake(12, 12))
                    }
                }
            }
            view!.canShowCallout = false
        } else {
            var customView:AccesorizedCalloutAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(calloutPin) as? AccesorizedCalloutAnnotationView {
                customView = dequeuedView
            } else {
                customView = AccesorizedCalloutAnnotationView(annotation: annotation, reuseIdentifier: calloutPin)
                
            }
            customView.mapView = mapView
            customView.parentAnnotationView = self.selectedMapAnnotationView!
            customView.annotation = annotation
            customView.contentHeight = 80.0
            if let annotation = self.selectedMapAnnotationView?.annotation as? FoursquareLocationMapAnnotation {
                customView.contentView().subviews.map({$0.removeFromSuperview()})
                let contentFrame = customView.getContentFrame()
                if let let categoryImageName = annotation.categoryImageName64 {
                    if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                        var aView = FoursquareAnnotationVenueInformationView()
                        aView.image = image
                        aView.name = annotation.title
                        aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                        aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                        customView.contentView().addSubview(aView)
                    }
                } else {
                    if let image = ImageCache.sharedInstance().imageWithIdentifier("default_64") {
                        var aView = FoursquareAnnotationVenueInformationView()
                        aView.image = image
                        aView.name = annotation.title
                        aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                        aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                        customView.contentView().subviews.map({$0.removeFromSuperview()})
                        customView.contentView().addSubview(aView)
                    }
                }
            }
            customView.superview?.bringSubviewToFront(customView)
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