//
//  FoursquareVenueDetailsAnnotationView.swift
//  uerani
//
//  Created by nacho on 8/17/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

class FoursquareVenueDetailsAnnotationView : AccesorizedCalloutAnnotationView {
    
    func configure(mapView: MKMapView, selectedAnnotationView:MKAnnotationView?, annotation:MKAnnotation) {
        self.mapView = mapView
        self.parentAnnotationView = selectedAnnotationView
        self.annotation = annotation
        self.contentHeight = 80.0
        if let annotation = self.parentAnnotationView?.annotation as? FoursquareLocationMapAnnotation {
            self.contentView().subviews.map({$0.removeFromSuperview()})
            let contentFrame = self.getContentFrame()
            if let let categoryImageName = annotation.categoryImageName64 {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                    var aView = FoursquareAnnotationVenueInformationView()
                    aView.image = image
                    aView.name = annotation.title
                    aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                    aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                    self.contentView().addSubview(aView)
                } else if let image = ImageCache.sharedInstance().imageWithIdentifier("default_64") {
                    var aView = FoursquareAnnotationVenueInformationView()
                    aView.image = image
                    aView.name = annotation.title
                    aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                    aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                    self.contentView().subviews.map({$0.removeFromSuperview()})
                    self.contentView().addSubview(aView)
                }
            } else {
                if let image = ImageCache.sharedInstance().imageWithIdentifier("default_64") {
                    var aView = FoursquareAnnotationVenueInformationView()
                    aView.image = image
                    aView.name = annotation.title
                    aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                    aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                    self.contentView().subviews.map({$0.removeFromSuperview()})
                    self.contentView().addSubview(aView)
                }
            }
        }
        self.superview?.bringSubviewToFront(self)
    }
}


