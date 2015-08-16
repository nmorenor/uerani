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
    
    let yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    
    override var image:UIImage! {
        didSet {
            self.prepareFrameSize()
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
        self.frame = CGRectMake(0, 0, image.size.width + 5, image.size.height + 7)
    }
    
    override func drawRect(rect: CGRect) {
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        yellowColor.setFill()
        var path:CGMutablePathRef = CGPathCreateMutable()
        var nrect:CGRect = CGRectMake(0, 0, image.size.width + 2, image.size.height + 2)
        CGContextSetLineWidth(context, 0);
        var radius:CGFloat = 5.0
        
        CGPathMoveToPoint(path, nil, nrect.origin.x, nrect.origin.y + radius)
        CGPathAddLineToPoint(path, nil, nrect.origin.x, nrect.origin.y + nrect.size.height - radius)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI_2), 0.0, true)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + radius, radius, 0.0, CGFloat(-M_PI_2), true)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + radius, radius, CGFloat(-M_PI_2), CGFloat(M_PI), true)
        CGPathCloseSubpath(path)
        
        // Fill & stroke the path
        CGContextAddPath(context, path)
        CGContextSaveGState(context)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        var trianglePath:CGMutablePathRef = CGPathCreateMutable()
        var originY:CGFloat = image.size.height + 2
        var originX:CGFloat = nrect.size.width / 2
        CGPathMoveToPoint(trianglePath, nil, originX + 5, originY)
        CGPathAddLineToPoint(trianglePath, nil, originX, originY + 7)
        CGPathAddLineToPoint(trianglePath, nil, originX - 5, originY)
        CGPathAddLineToPoint(trianglePath, nil, originX + 5, originY)
        CGPathCloseSubpath(trianglePath)
        
        //fill & shadow
        CGContextAddPath(context, trianglePath)
        CGContextSaveGState(context)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        //draw the image in black
        UIColor.blackColor().setFill()
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        var flipVertical:CGAffineTransform = CGAffineTransformMake(1, 0, 0, -1, 0, image.size.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        var imageRect = CGRectMake(1.0, -2.5, image.size.width, image.size.height)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        CGContextClipToMask(context, imageRect, image.CGImage)
        CGContextAddRect(context, imageRect)
        CGContextDrawPath(context, kCGPathFill)
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
