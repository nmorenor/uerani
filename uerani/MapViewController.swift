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
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        let requestProcessor = LocationRequestManager.sharedInstance().requestProcessor
        if let calloutAnnotation = requestProcessor.calloutAnnotation {
            mapView.removeAnnotation(calloutAnnotation)
            requestProcessor.calloutAnnotation = nil
        }
        requestProcessor.calloutAnnotation = CalloutAnnotation(coordinate: view.annotation.coordinate)
        requestProcessor.selectedMapAnnotationView = view
        mapView.addAnnotation(requestProcessor.calloutAnnotation!)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        
        let identifier = "foursquarePin"
        let clusterPin = "foursquareClusterPin"
        let calloutPin = "calloutPin"
        var view:MKPinAnnotationView?
        if let annotation = annotation as? FBAnnotationCluster {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(clusterPin) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: clusterPin)
            }
            self.drawCircleImage(annotation, view: view!)
            
        } else if let annotation = annotation as? FoursquareLocationMapAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if let categoryImageName = annotation.categoryImageName {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                    self.drawCategoryImage(view!, image: image)
                } else if let prefix = annotation.categoryPrefix, let suffix = annotation.categorySuffix {
                    FoursquareCategoryIconWorker(prefix: prefix, suffix: suffix)
                    if let image = ImageCache.sharedInstance().imageWithIdentifier("default_32.png") {
                        self.drawCategoryImage(view!, image: image)
                    }
                } else {
                    if let image = ImageCache.sharedInstance().imageWithIdentifier("default_32.png") {
                        self.drawCategoryImage(view!, image: image)
                    }
                }
            }
            view!.canShowCallout = false
        }
        if let view = view {
            return view
        }
        
        var customView:CalloutMapAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(calloutPin) as? CalloutMapAnnotationView {
            dequeuedView.mapView = mapView
            dequeuedView.parentAnnotationView = LocationRequestManager.sharedInstance().requestProcessor.selectedMapAnnotationView!
            dequeuedView.annotation = annotation
            customView = dequeuedView
        } else {
            customView = CalloutMapAnnotationView(annotation: annotation, reuseIdentifier: calloutPin)
            customView.mapView = mapView
            customView.parentAnnotationView = LocationRequestManager.sharedInstance().requestProcessor.selectedMapAnnotationView!
        }
        if let image = ImageCache.sharedInstance().imageWithIdentifier("default_32.png") {
            var aView = UIImageView(image: image)
            aView.frame = CGRectMake(5, 2, aView.frame.size.width, aView.frame.size.height)
            customView.contentView().addSubview(aView)
        }
        
        
        return customView
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if LocationRequestManager.sharedInstance().requestProcessor.isRefreshReady() {
            RefreshMapAnnotationOperation(mapView: mapView)
        }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        if fullyRendered && LocationRequestManager.sharedInstance().requestProcessor.isRefreshReady() {
            LocationRequestManager.sharedInstance().requestProcessor.triggerLocationSearch(mapView.region)
        }
    }
    
    func drawCategoryImage(view:MKPinAnnotationView, image:UIImage) {
        let containerLayer = CALayer()
        var yellowColor = UIColor(red: 255.0/255.0, green: 188.0/255.0, blue: 8/255.0, alpha: 1.0)
        containerLayer.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height + 30)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, image.size.width + 10, image.size.height + 10)).CGPath
        circleLayer.fillColor = yellowColor.CGColor
        circleLayer.backgroundColor = UIColor.clearColor().CGColor
        
        let triangleLayer = CAShapeLayer()
        triangleLayer.frame = CGRectMake(0, image.size.height - ((image.size.height / 4) + 2), image.size.width + 10, 30)
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0, y: 0))
        bezierPath.addLineToPoint(CGPoint(x: (image.size.width + 10) / 2, y: 30))
        bezierPath.addLineToPoint(CGPoint(x: image.size.width + 10, y: 0))
        
        bezierPath.closePath()
        triangleLayer.path = bezierPath.CGPath
        triangleLayer.fillColor = yellowColor.CGColor
        triangleLayer.backgroundColor = UIColor.clearColor().CGColor
        
        let imageLayer = CALayer()
        imageLayer.frame = CGRectMake(5, 5, image.size.width, image.size.height)
        imageLayer.contents = image.CGImage
        
        containerLayer.addSublayer(circleLayer)
        containerLayer.addSublayer(triangleLayer)
        containerLayer.addSublayer(imageLayer)
        
        UIGraphicsBeginImageContextWithOptions(containerLayer.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        containerLayer.renderInContext(context)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = resultImage
    }
    
    func drawCircleImage(annotation:FBAnnotationCluster, view:MKPinAnnotationView) {
        let number = annotation.annotations.count
        
        let fontSize:CGFloat = number > 9 ? 30 : 20
        var font = UIFont(name: "Helvetica", size: fontSize)!
        var yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
        var attributedString = NSAttributedString(string: String(annotation.annotations.count), attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: yellowColor])
        let asize:CGSize = attributedString.size()
        let size = max((asize.width + 10), 30)
        
        let label = CATextLayer()
        label.frame = CGRectMake(5, ((((size - 5) - fontSize) / 2) + 5), size, size)
        label.alignmentMode = kCAAlignmentCenter
        label.allowsEdgeAntialiasing = true
        label.string = attributedString
        label.backgroundColor = UIColor.clearColor().CGColor
        label.foregroundColor = yellowColor.CGColor

        let backCircle = CAShapeLayer()
        backCircle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, size + 10, size + 10)).CGPath
        backCircle.fillColor = yellowColor.CGColor
        backCircle.backgroundColor = UIColor.clearColor().CGColor
        
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRectMake(5, 5, size, size)).CGPath
        circle.fillColor = UIColor.blackColor().CGColor
        circle.backgroundColor = UIColor.clearColor().CGColor
        backCircle.addSublayer(circle)
        circle.addSublayer(label)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size + 10, height: size + 10), false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        backCircle.renderInContext(context)
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

