//
//  VenueMapView.swift
//  uerani
//
//  Created by nacho on 9/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

@IBDesignable
public class VenueMapView : UIView {
    
    let photoLayer = CALayer()
    let polygonLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    var topPath:UIBezierPath?
    
    var image: UIImage? {
        didSet {
            if let image = self.image {
                //photoLayer.contents = image.CGImage
            } else {
                photoLayer.contents = nil
            }
        }
    }
    
    func createBezierPath(rect: CGRect) {
        self.topPath = UIBezierPath()
        
        self.topPath!.moveToPoint(CGPointMake(rect.size.width, rect.origin.y))
        self.topPath!.addLineToPoint(CGPointMake(rect.size.width, rect.origin.y + rect.height))
        self.topPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y + rect.height))
        self.topPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y))
        
        var arcHeight:CGFloat = rect.size.height *  0.15
        var arcRect:CGRect = CGRectMake(rect.origin.x, rect.origin.y - arcHeight, rect.size.width, arcHeight)
        
        var arcRadius:CGFloat = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height))
        var arcCenter:CGPoint  = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius)
        
        var angle:CGFloat = acos(arcRect.size.width / (2*arcRadius))
        var startAngle:CGFloat = (CGFloat(toRadian(180)) + angle)
        var endAngle:CGFloat = (CGFloat(toRadian(360)) - angle)
        self.topPath!.addArcWithCenter(arcCenter, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        self.topPath!.closePath()
    }
    
    override public func didMoveToWindow() {
        photoLayer.mask = maskLayer
        
        layer.addSublayer(photoLayer)
        layer.addSublayer(polygonLayer)
    }
    
    override public func layoutSubviews() {
        self.createBezierPath(self.frame)
        
        //Size the avatar image to fit
        if let image = self.image {
            photoLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: image.size.width,
                height: image.size.height)
        }
        
        polygonLayer.path = self.topPath!.CGPath
        polygonLayer.fillColor = UIColor.ueraniBlackJetColor().CGColor

        
        //Size the layer
        maskLayer.path = polygonLayer.path
        maskLayer.position = CGPoint(x: 0.0, y: 0.0)
        
    }
}