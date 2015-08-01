//
//  AccesorizedCalloutAnnotationView.swift
//  uerani
//
//  Created by nacho on 7/31/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit

class AccesorizedCalloutAnnotationView: CalloutMapAnnotationView {
    
    var accessory:UIButton
    
    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        self.accessory = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        self.accessory.exclusiveTouch = true
        self.accessory.enabled = true
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.accessory.addTarget(self, action: "calloutAccessoryTapped:", forControlEvents: UIControlEvents.TouchUpInside | UIControlEvents.TouchCancel)
        self.addSubview(self.accessory)
    }
    
    override init(frame: CGRect) {
        self.accessory = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        self.accessory.exclusiveTouch = true
        self.accessory.enabled = true
        super.init(frame: frame)
        self.accessory.addTarget(self, action: "calloutAccessoryTapped:", forControlEvents: UIControlEvents.TouchUpInside | UIControlEvents.TouchCancel)
        self.addSubview(self.accessory)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.prepareAccessoryFrame()
    }

    override func prepareContentFrame() {
        var nrect = self.getRectDraw()
        var contentFrame = CGRectMake(nrect.origin.x + 10, nrect.origin.y + 3, nrect.size.width - 20, self.contentHeight)
        self.contentView().frame = contentFrame
    }
    
    func prepareAccessoryFrame() {
        var nrect = self.getRectDraw()
        self.accessory.frame = CGRectMake(nrect.size.width - self.accessory.frame.size.width - 15, (self.contentHeight + 3 - self.accessory.frame.size.height) / 2, self.accessory.frame.size.width, self.accessory.frame.height)
    }
    
    func calloutAccessoryTapped(sender: UIButton!) {
        if let mapView = self.mapView where mapView.delegate.respondsToSelector(Selector("mapView:annotationView:calloutAccessoryControlTapped:")) {
            mapView.delegate.mapView!(mapView, annotationView: self.parentAnnotationView, calloutAccessoryControlTapped: sender)
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var hitView:UIView? = super.hitTest(point, withEvent: event)
        
        if let hitView = hitView {
            if hitView === self.accessory {
                self.preventParentSelectionChange()
                delay(seconds: 1.0, self.allowParentSelectionChange)
                if let superView = self.superview {
                    for sibling in superView.subviews {
                        if let sibling = sibling as? MKAnnotationView where sibling !== self.parentAnnotationView {
                            sibling.enabled = false
                            delay(seconds: 1.0) {
                                self.enableSibling(sibling)
                            }
                        }
                    }
                }
            }
        }
        
        return hitView
    }
    
    func enableSibling(sibling:UIView?) {
        if let sibling = sibling as? MKAnnotationView {
            sibling.enabled = true
        }
    }
    
    func preventParentSelectionChange() {
        if let parentView = self.parentAnnotationView as? BasicMapAnnotationView {
            parentView.preventSelectionChange = true
        }
    }
    
    func allowParentSelectionChange() {
        if let mapView = self.mapView {
            mapView.selectAnnotation(self.parentAnnotationView?.annotation, animated: false)
            let parentView = self.parentAnnotationView as! BasicMapAnnotationView
            parentView.preventSelectionChange = false
        }
    }
}
