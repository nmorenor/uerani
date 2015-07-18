//
//  MapViewController.swift
//  grabbed
//
//  Created by nacho on 6/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClustering
import RealmSwift

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationRequestManager = LocationRequestManager.sharedInstance()
        locationRequestManager.requestProcessor.mapView = self.mapView
        self.mapView.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let locationRequestManager = LocationRequestManager.sharedInstance()
        locationRequestManager.requestProcessor.mapView = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        
        let identifier = "foursquarePin"
        let clusterPin = "foursquareClusterPin"
        var view:MKPinAnnotationView
        if let annotation = annotation as? FBAnnotationCluster {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(clusterPin) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: clusterPin)
            }
            self.drawCircleImage(annotation, view: view)
        } else {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
        }
        
        return view
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        RefreshMapAnnotationOperation(mapView: mapView)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        if fullyRendered {
            LocationRequestManager.sharedInstance().requestProcessor.triggerLocationSearch()
        }
    }
    
    func drawCircleImage(annotation:FBAnnotationCluster, view:MKPinAnnotationView) {
        let number = annotation.annotations.count
        let size:CGFloat = number > 9 ? 45 : 35
        let fontSize:CGFloat = number > 9 ? 30 : 20
        
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, size, size)).CGPath
        circle.fillColor = UIColor.redColor().CGColor
        circle.backgroundColor = UIColor.clearColor().CGColor
        let label = CATextLayer()
        label.font = "Helvetica"
        label.fontSize = fontSize
        label.frame = CGRectMake(0, (((size - 5) - fontSize) / 2), size, size)
        label.alignmentMode = kCAAlignmentCenter
        label.allowsEdgeAntialiasing = true
        label.foregroundColor = UIColor.whiteColor().CGColor
        label.string = String(annotation.annotations.count)
        circle.addSublayer(label)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        circle.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = image
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
}

