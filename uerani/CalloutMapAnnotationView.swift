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
    var offsetFromParent:CGPoint = CGPointMake(8, -14)
    
    var mapView:MKMapView?
    var parentAnnotationView:MKAnnotationView?
    var endFrame:CGRect!
    var _yShadowOffset:CGFloat?
    var _contentView:UIView?
    
    override var annotation: MKAnnotation! {
        didSet {
            self.prepareFrameSize()
            self.prepareOffset()
            self.prepareContentFrame()
            self.setNeedsDisplay()
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override init!(annotation: MKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clearColor()
        
        self.prepareFrameSize()
        self.prepareOffset()
        self.prepareContentFrame()
        self.setNeedsDisplay()
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
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView {
            //longitude
            var xPixelShift:CGFloat = 0.0
            if self.relativeParentXPosition() < 38 {
                xPixelShift = 38.0 - self.relativeParentXPosition()
            } else if self.relativeParentXPosition() > self.frame.size.width - 38 {
                xPixelShift = (self.frame.size.width - 38.0) - self.relativeParentXPosition()
            }
            
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
                var pixelsPerDegreeLongitude:CGFloat = mapView.frame.size.width / CGFloat(mapView.region.span.longitudeDelta)
                var pixelsPerDegreeLatitude:CGFloat = mapView.frame.size.height / CGFloat(mapView.region.span.latitudeDelta)
            
                let longitudinalShift:CLLocationDegrees = Double(-(xPixelShift / pixelsPerDegreeLongitude))
                let latitudinalShift:CLLocationDegrees = Double(yPixelShift/pixelsPerDegreeLatitude)
            
                let newCenterCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mapView.region.center.latitude + latitudinalShift, longitude: mapView.region.center.longitude + longitudinalShift)
            
                mapView.setCenterCoordinate(newCenterCoordinate, animated: true)
            
                self.frame = CGRectMake(self.frame.origin.x - xPixelShift, self.frame.origin.y - yPixelShift, self.frame.size.width, self.frame.size.height)
            
                self.centerOffset = CGPointMake(self.centerOffset.x - xPixelShift, self.centerOffset.y)
            }
        }
    }
    
    func relativeParentXPosition() -> CGFloat {
        if let mapView = self.mapView, let parentAnnotationView = self.parentAnnotationView {
            var parentOrigin:CGPoint = mapView.convertPoint(parentAnnotationView.frame.origin, fromView: parentAnnotationView.superview)
            return parentOrigin.x + self.offsetFromParent.x
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
        var parentX:CGFloat = self.relativeParentXPosition()
        
        //determine size
        var nrect = self.bounds
        nrect.size.width -= stroke + 14
        nrect.size.height -= stroke + heightAboveParent - self.offsetFromParent.y + bottomShadowBufferSize
        nrect.origin.x += stroke / 2.0 + 7
        nrect.origin.y += stroke / 2.0
        
        //Create Path For Callout Bubble
        CGPathMoveToPoint(path, nil, nrect.origin.x, nrect.origin.y + radius)
        CGPathAddLineToPoint(path, nil, nrect.origin.x, nrect.origin.y + nrect.size.height - radius)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        CGPathAddLineToPoint(path, nil, parentX - 15, nrect.origin.y + nrect.size.height + 15)
        CGPathAddLineToPoint(path, nil, parentX, nrect.origin.y + nrect.size.height)
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
        
        //get size for gloss
        var glossRect:CGRect = self.bounds
        glossRect.size.width = rect.size.width - stroke
        glossRect.size.height = (rect.size.height - stroke) / 2
        glossRect.origin.x = nrect.origin.x + stroke / 2
        glossRect.origin.y += rect.origin.y + stroke / 2
        
        var glossTopRadius:CGFloat = radius - stroke / 2
        var glossBottomRadius:CGFloat = radius / 1.5
        
        var glossPath:CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(glossPath, nil, glossRect.origin.x, glossRect.origin.y + glossTopRadius)
        CGPathAddLineToPoint(glossPath, nil, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius)
        CGPathAddArc(glossPath, nil, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height, glossBottomRadius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        CGPathAddLineToPoint(glossPath, nil, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height)
        CGPathAddArc(glossPath, nil, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, CGFloat(M_PI_2), 0.0, true)
        CGPathAddLineToPoint(glossPath, nil, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius)
        CGPathAddArc(glossPath, nil, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, 0.0, CGFloat(-M_PI/2), true)
        CGPathAddLineToPoint(glossPath, nil, glossRect.origin.x + glossTopRadius, glossRect.origin.y)
        CGPathAddArc(glossPath, nil, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, CGFloat(-M_PI_2), CGFloat(M_PI), true)
        CGPathCloseSubpath(glossPath)
        
        //fill gloss
        CGContextAddPath(context, glossPath)
        CGContextClip(context)
        var colors:Array<CGFloat> = [1, 1, 1, 0.3, 1, 1, 1, 0.1]
        var locations:Array<CGFloat> = [0, 1.0]
        var gradient:CGGradientRef = CGGradientCreateWithColorComponents(space, colors, locations, 2)
        var startPoint:CGPoint = glossRect.origin
        var endPoint:CGPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
        
        //stroke gloss path
        CGContextAddPath(context, glossPath)
        CGContextSetLineWidth(context, 2)
        CGContextReplacePathWithStrokedPath(context)
        CGContextClip(context)
        var colors2:Array<CGFloat> = [1, 1, 1, 0.3,
                                    1, 1, 1,0.1,
                                    1, 1, 1,0.0]
        var locations2:Array<CGFloat> = [0, 0.1, 1.0]
        var gradient2:CGGradientRef = CGGradientCreateWithColorComponents(space, colors2, locations2, 3)
        var startPoint2:CGPoint = glossRect.origin
        var endPoint2:CGPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height)
        CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0)
        
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
