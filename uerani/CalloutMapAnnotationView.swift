//
//  CalloutMapAnnotationView.swift
//  uerani
//
//  Created by nacho on 7/22/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit

class CalloutMapAnnotationView: MKAnnotationView {

    let bottomShadowBufferSize:CGFloat = 6.0
    let contentHeightBuffer:CGFloat = 8.0
    let heightAboveParent:CGFloat = 2.0
    
    var contentHeight:CGFloat = 80.0
    var offsetFromParent:CGPoint = CGPointMake(6, -7)
    
    var mapView:MKMapView?
    var parentAnnotationView:MKAnnotationView?
    var endFrame:CGRect!
    var _yShadowOffset:CGFloat?
    var _contentView:UIView?
    var alreadyOpen = false
    var adjustedRegionShift:CGFloat = -1
    
    override var annotation: MKAnnotation! {
        didSet {
            self.alreadyOpen = false
            self.prepareFrameSize()
            self.prepareOffset()
            self.prepareContentFrame()
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareFrameSize() {
        if let mapView = self.mapView {
            var frame = self.frame
            let height = self.contentHeight + contentHeightBuffer + bottomShadowBufferSize - self.offsetFromParent.y
            
            frame.size = CGSizeMake(mapView.frame.size.width, height)
            self.frame = frame
        }
    }
    
    func prepareContentFrame() {
        let contentFrame = CGRectMake(self.bounds.origin.x + 10, self.bounds.origin.y + 3, self.bounds.size.width - 20, self.contentHeight)
        self.contentView().frame = contentFrame
        
    }
    
    func prepareOffset() {
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView {
            var parentOrigin:CGPoint = mapView.convertPoint(parentAnnotationView.frame.origin, fromView: parentAnnotationView.superview)
            var xOffset = (mapView.frame.size.width / 2.0) - (parentOrigin.x + self.offsetFromParent.x)
            
            var yOffset = -(self.frame.size.height / 2 + parentAnnotationView.frame.size.height / 2) + self.offsetFromParent.y + bottomShadowBufferSize
            self.centerOffset = CGPointMake(xOffset, yOffset)
        }
    }
    
    func adjustMapRegionIfNeeded() {
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView where !self.alreadyOpen {
            //longitude
            var xPixelShift:CGFloat = self.getXPixelShift()
            //latitude
            var mapViewOriginRelativeToParent = mapView.convertPoint(mapView.frame.origin, toView: parentAnnotationView)
            var yPixelShift:CGFloat = 0.0
            var pixelsFromTopOfMapView = -(mapViewOriginRelativeToParent.y + self.frame.size.height - bottomShadowBufferSize)
            var pixelsFromBottomOfMapView = mapView.frame.size.height + mapViewOriginRelativeToParent.y - parentAnnotationView.frame.size.height
            
            if pixelsFromTopOfMapView < 7 {
                yPixelShift = 7 - pixelsFromTopOfMapView
            } else if pixelsFromBottomOfMapView < 10 {
                yPixelShift = -(10 - pixelsFromBottomOfMapView)
            }
        
            if (xPixelShift != 0 || yPixelShift != 0) {
                if xPixelShift == 0 {
                    self.adjustedRegionShift = -1
                } else {
                    self.adjustedRegionShift = xPixelShift
                }
                var pixelsPerDegreeLongitude:CGFloat = mapView.frame.size.width / CGFloat(mapView.region.span.longitudeDelta)
                var pixelsPerDegreeLatitude:CGFloat = mapView.frame.size.height / CGFloat(mapView.region.span.latitudeDelta)
            
                let longitudinalShift:CLLocationDegrees = Double(-(xPixelShift / pixelsPerDegreeLongitude))
                let latitudinalShift:CLLocationDegrees = Double(yPixelShift/pixelsPerDegreeLatitude)
            
                let newCenterCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mapView.region.center.latitude + latitudinalShift, longitude: mapView.region.center.longitude + longitudinalShift)
            
                mapView.setCenterCoordinate(newCenterCoordinate, animated: true)
            
                self.frame = CGRectMake(self.frame.origin.x - xPixelShift, self.frame.origin.y - yPixelShift, self.frame.size.width, self.frame.size.height)
            
                self.centerOffset = CGPointMake(self.centerOffset.x - xPixelShift, self.centerOffset.y)
            } else if xPixelShift == 0 {
                self.adjustedRegionShift = -1
            }
        }
        self.alreadyOpen = true
    }
    
    func getXPixelShift() -> CGFloat {
        var xPixelShift:CGFloat = 0
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView {
            
            if self.relativeParentXPosition() < 38 {
                xPixelShift = 38 - self.relativeParentXPosition()
            } else if self.relativeParentXPosition() > (self.frame.size.width - 88) {
                xPixelShift = (self.frame.size.width - 88) - self.relativeParentXPosition()
            }
        }
        return xPixelShift
    }
    
    func relativeParentXPosition() -> CGFloat {
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView {
            var parentOrigin:CGPoint = mapView.convertPoint(parentAnnotationView.frame.origin, fromView: parentAnnotationView.superview)
            return parentOrigin.x - self.offsetFromParent.x
        }
        return 0.0
    }
    
    func xTransformForScale(scale:CGFloat) -> CGFloat {
        let xDistanceFromCenterToParent = self.endFrame.size.width / 2 - self.relativeParentXPosition()
        return (xDistanceFromCenterToParent * scale) - xDistanceFromCenterToParent
    }
    
    func yTransformForScale(scale:CGFloat) -> CGFloat {
        let yDistanceFromCenterToParent = (((self.endFrame.size.height) / 2) + self.offsetFromParent.y + bottomShadowBufferSize + heightAboveParent )
        return yDistanceFromCenterToParent - (yDistanceFromCenterToParent * scale)
    }
    
    func animateIn() {
        self.endFrame = self.frame
        var scale:CGFloat = 0.001
        self.transform = CGAffineTransformMake(scale, 0.0, 0.0, scale, self.xTransformForScale(scale), self.yTransformForScale(scale))
        
        UIView.beginAnimations("animateIn", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
        UIView.setAnimationDuration(0.075)
        UIView.setAnimationDidStopSelector("animateInStepTwo")
        UIView.setAnimationDelegate(self)
        scale = 1.1
        self.transform = CGAffineTransformMake(scale, 0.0, 0.0, scale, self.xTransformForScale(scale), self.yTransformForScale(scale))
        UIView.commitAnimations()
    }
    
    func animateInStepTwo() {
        UIView.beginAnimations("animateInStepTwo", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.1)
        UIView.setAnimationDidStopSelector("animateInStepThree")
        UIView.setAnimationDelegate(self)
        
        var scale:CGFloat = 0.95
        self.transform = CGAffineTransformMake(scale, 0.0, 0.0, scale, self.xTransformForScale(scale), self.yTransformForScale(scale))
        
        UIView.commitAnimations()
    }
    
    func animateInStepThree() {
        UIView.beginAnimations("animateInStepThree", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationDuration(0.075)
        
        var scale:CGFloat = 1.0
        self.transform = CGAffineTransformMake(scale, 0.0, 0.0, scale, self.xTransformForScale(scale), self.yTransformForScale(scale))
        UIView.commitAnimations()
    }
    
    override func didMoveToSuperview() {
        self.adjustMapRegionIfNeeded()
        self.animateIn()
    }
    
    override func drawRect(rect: CGRect) {
        var stroke:CGFloat = 1.0
        var radius:CGFloat = 7.0
        var path:CGMutablePathRef = CGPathCreateMutable()
        
        var space:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var context:CGContextRef = UIGraphicsGetCurrentContext();
        
        
        /**
        * In case of pixel shift, when the map view is moving to display the annotaiton
        * use the shift to draw the rect, so the triangle is not out of the rectangle
        **/
        var parentX:CGFloat = self.getParentX()
        var nrect = self.getRectDraw()
        
        //Create Path For Callout Bubble
        CGPathMoveToPoint(path, nil, nrect.origin.x, nrect.origin.y + radius)
        CGPathAddLineToPoint(path, nil, nrect.origin.x, nrect.origin.y + nrect.size.height - radius)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        CGPathAddLineToPoint(path, nil, parentX - 15, nrect.origin.y + nrect.size.height)
        CGPathAddLineToPoint(path, nil, parentX, nrect.origin.y + nrect.size.height + 15)
        CGPathAddLineToPoint(path, nil, parentX + 15, nrect.origin.y + nrect.size.height)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + nrect.size.height)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI_2), 0.0, true)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + nrect.size.width, nrect.origin.y + radius)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + radius, radius, 0.0, CGFloat(-M_PI_2), true)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + radius, nrect.origin.y)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + radius, radius, CGFloat(-M_PI_2), CGFloat(M_PI), true)
        CGPathCloseSubpath(path)
        
        var color:UIColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        color.setFill()
        
        //fill & shadow
        CGContextAddPath(context, path)
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, CGSizeMake(0, self.yShadowOffset()), 6, UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        //stroke
        color = UIColor.darkGrayColor().colorWithAlphaComponent(0.9)
        color.setStroke()
        CGContextSetLineWidth(context, stroke)
        CGContextSetLineCap(context, kCGLineCapSquare)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
    }
    
    func getParentX() -> CGFloat {
        return self.adjustedRegionShift != -1 ? self.relativeParentXPosition() + self.adjustedRegionShift : self.relativeParentXPosition()
    }
    
    func getRectDraw() -> CGRect {
        var stroke:CGFloat = 1.0
        var nrect = self.bounds
        nrect.size.width -= stroke + 14
        nrect.size.height -= stroke + heightAboveParent - self.offsetFromParent.y + bottomShadowBufferSize
        nrect.origin.x += stroke / 2.0
        nrect.origin.y += stroke / 2.0
        
        return nrect
    }
    
    func yShadowOffset() -> CGFloat {
        if _yShadowOffset == nil {
            var osVersion = NSString(string: UIDevice.currentDevice().systemVersion).floatValue
            if osVersion >= 3.2 {
                _yShadowOffset = 6
            } else {
                _yShadowOffset = -6
            }
        }
        
        return _yShadowOffset!
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.superview?.bringSubviewToFront(self)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func contentView() -> UIView {
        if let contentView = self._contentView {
            return contentView
        }
        self._contentView = UIView()
        self._contentView?.backgroundColor = UIColor.clearColor()
        self._contentView?.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.addSubview(self._contentView!)
        
        return self._contentView!
    }
    
    deinit {
        self.parentAnnotationView = nil
        self.mapView = nil
        self._contentView = nil
    }
}
