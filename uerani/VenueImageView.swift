//
//  VenueImageView.swift
//  uerani
//
//  Created by nacho on 9/7/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

@IBDesignable
public class VenueImageView : UIView {
    
    let photoLayer = CALayer()
    let polygonLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    var topPath:UIBezierPath?
    
    let mapPhotoLayer = CALayer()
    let mapPolygonLayer = CAShapeLayer()
    let mapMaskLayer = CAShapeLayer()
    var mapPath:UIBezierPath?
    
    let gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        let colors = [
            UIColor.ueraniBlackJetColor().CGColor,
            UIColor.ueraniYellowColor().CGColor
        ]
        
        let locations = [
            0.0,
            0.5
        ]
        
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        return gradientLayer
        }()
    
    var image: UIImage? {
        didSet {
            if let image = self.image {
                photoLayer.contents = image.CGImage
            } else {
                photoLayer.contents = nil
            }
        }
    }
    
    var mapImage: UIImage? {
        didSet {
            if let mapImage = self.mapImage {
                mapPhotoLayer.contents = mapImage.CGImage
            } else {
                mapPhotoLayer.contents = nil
            }
        }
    }
    
    func createBezierPath(rect: CGRect) {
        self.topPath = UIBezierPath()
        self.topPath!.moveToPoint(CGPointMake(rect.size.width, rect.origin.y + rect.height))
        self.topPath!.addLineToPoint(CGPointMake(rect.size.width, rect.origin.y))
        self.topPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y))
        self.topPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y + rect.height))
    
        var arcHeight:CGFloat = rect.size.height *  0.15
        var arcRect:CGRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight)
        
        var arcRadius:CGFloat = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height))
        var arcCenter:CGPoint  = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius)
        
        var angle:CGFloat = acos(arcRect.size.width / (2*arcRadius))
        var startAngle:CGFloat = (CGFloat(toRadian(180)) + angle)
        var endAngle:CGFloat = (CGFloat(toRadian(360)) - angle)
        self.topPath!.addArcWithCenter(arcCenter, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        self.topPath!.closePath()
    }
    
    //basically the same but different points and arcRect
    func createMapBezierPath(rect: CGRect) {
        self.mapPath = UIBezierPath()
        
        self.mapPath!.moveToPoint(CGPointMake(rect.size.width, rect.origin.y))
        self.mapPath!.addLineToPoint(CGPointMake(rect.size.width, rect.origin.y + rect.height))
        self.mapPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y + rect.height))
        self.mapPath!.addLineToPoint(CGPointMake(rect.origin.x, rect.origin.y))
        
        var arcHeight:CGFloat = rect.size.height *  0.15
        var arcRect:CGRect = CGRectMake(rect.origin.x, rect.height - arcHeight, rect.size.width, arcHeight)
        
        var arcRadius:CGFloat = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height))
        var arcCenter:CGPoint  = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius)
        
        var angle:CGFloat = acos(arcRect.size.width / (2*arcRadius))
        var startAngle:CGFloat = (CGFloat(toRadian(180)) + angle)
        var endAngle:CGFloat = (CGFloat(toRadian(360)) - angle)
        self.mapPath!.addArcWithCenter(arcCenter, radius: arcRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        self.mapPath!.closePath()
    }
    
    override public func didMoveToWindow() {
        photoLayer.mask = maskLayer
        
        layer.addSublayer(photoLayer)
        layer.addSublayer(polygonLayer)
        
        mapPhotoLayer.mask = mapMaskLayer
        
        layer.addSublayer(mapPhotoLayer)
        layer.addSublayer(mapPolygonLayer)
    }
    
    override public func layoutSubviews() {
        self.createBezierPath(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2))
        self.createMapBezierPath(CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2))
        
        //Size the avatar image to fit
        if let image = self.image {
            photoLayer.frame = CGRect(
                x: 0,
                y: 0,
                width: image.size.width,
                height: image.size.height)
        }
        
        polygonLayer.path = self.topPath!.CGPath
        polygonLayer.fillColor = self.image == nil ? UIColor.blackColor().CGColor : UIColor.clearColor().CGColor
        
        //Size the layer
        maskLayer.path = polygonLayer.path
        maskLayer.position = CGPoint(x: 0.0, y: 0.0)
        
        if let image = self.mapImage {
            mapPhotoLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height)
            gradientLayer.frame = CGRectMake(0, self.frame.size.height - 10, mapPhotoLayer.frame.size.width, 10)
            layer.addSublayer(gradientLayer)
        }
        
        mapPolygonLayer.path = self.mapPath!.CGPath
        mapPolygonLayer.fillColor = self.mapImage == nil ? UIColor.blackColor().CGColor : UIColor.clearColor().CGColor
        
        //Size the layer
        mapMaskLayer.path = mapPolygonLayer.path
        mapMaskLayer.position = CGPoint(x: 0.0, y: 0.0)
        
    }
}