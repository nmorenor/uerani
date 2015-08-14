//
//  CategoryPinAnnotaitonView.swift
//  uerani
//
//  Created by nacho on 8/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CategoryPinAnnotationView : BasicMapAnnotationView {
    
    override var annotation: MKAnnotation! {
        didSet {
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
    
    override func didMoveToSuperview() {
        layer.sublayers = nil
        
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
        
        layer.addSublayer(containerLayer)
    }
    
    static func resizeImage(image:UIImage, newSize:CGSize) -> UIImage {
        var newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        var imageRef:CGImageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        var flipVertical:CGAffineTransform = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        // Get the resized image from the context and a UIImage
        var newImage:UIImage = UIImage(CGImage: CGBitmapContextCreateImage(context))!
        
        UIGraphicsEndImageContext();
        return newImage
    }
}
