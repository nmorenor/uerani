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
    let defaultPinImage = "default_32.png"
    
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
        self.frame = CGRectMake(0, 0, image.size.width + 5, image.size.height + 10)
    }
    
    func configure(foursquareAnnotation:FoursquareLocationMapAnnotation) {
        if let categoryImageName = foursquareAnnotation.categoryImageName {
            if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                if let image12 = ImageCache.sharedInstance().imageWithIdentifier(foursquareAnnotation.categoryImageName12) {
                    self.image = image12
                } else {
                    var image12 = image.resizeImage(CGSizeMake(12, 12))
                    ImageCache.sharedInstance().storeImage(image12, withIdentifier: foursquareAnnotation.categoryImageName12!)
                    self.image = image12
                }
            } else if let prefix = foursquareAnnotation.categoryPrefix, let suffix = foursquareAnnotation.categorySuffix {
                FoursquareCategoryIconWorker(prefix: prefix, suffix: suffix)
                if let image = UIImage(named: defaultPinImage) {
                    self.image = image.resizeImage(CGSizeMake(12, 12))
                }
            } else {
                if let image = UIImage(named: defaultPinImage) {
                    self.image = image.resizeImage(CGSizeMake(12, 12))
                }
            }
        }
        self.canShowCallout = false
    }
    
    override func drawRect(rect: CGRect) {
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        yellowColor.setFill()
        UIColor.blackColor().setStroke()
        var path:CGMutablePathRef = CGPathCreateMutable()
        var stroke:CGFloat = 1.5
        var nrect:CGRect = CGRectMake(0, 0, image.size.width + 2, image.size.height + 2)
        nrect.size.width -= stroke
        nrect.size.height -= stroke
        nrect.origin.x += stroke / 2.0
        nrect.origin.y += stroke / 2.0
        
        CGContextSetLineWidth(context, stroke);
        var radius:CGFloat = 5.0
        
        //reference point for triangle
        var originX:CGFloat = nrect.size.width / 2
        
        CGPathMoveToPoint(path, nil, nrect.origin.x, nrect.origin.y + radius)
        CGPathAddLineToPoint(path, nil, nrect.origin.x, nrect.origin.y + nrect.size.height - radius)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI), CGFloat(M_PI_2), true)
        //draw triangle
        CGPathAddLineToPoint(path, nil, originX - 5, nrect.origin.y + nrect.size.height)
        CGPathAddLineToPoint(path, nil, originX, nrect.origin.y + nrect.size.height + 8)
        CGPathAddLineToPoint(path, nil, originX + 5, nrect.origin.y + nrect.size.height)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + nrect.size.height)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + nrect.size.height - radius, radius, CGFloat(M_PI_2), 0.0, true)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + nrect.size.width, nrect.origin.y + radius)
        CGPathAddArc(path, nil, nrect.origin.x + nrect.size.width - radius, nrect.origin.y + radius, radius, 0.0, CGFloat(-M_PI_2), true)
        CGPathAddLineToPoint(path, nil, nrect.origin.x + radius, nrect.origin.y)
        CGPathAddArc(path, nil, nrect.origin.x + radius, nrect.origin.y + radius, radius, CGFloat(-M_PI_2), CGFloat(M_PI), true)
        CGPathCloseSubpath(path)
        
        // Fill & stroke the path
        CGContextAddPath(context, path)
        CGContextSaveGState(context)
        CGContextDrawPath(context, kCGPathFillStroke);
        CGContextRestoreGState(context)
        
        //draw the image in black
        UIColor.blackColor().setFill()
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        var flipVertical:CGAffineTransform = CGAffineTransformMake(1, 0, 0, -1, 0, image.size.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        var imageRect = CGRectMake(1.0, -1.5, image.size.width, image.size.height)
        CGContextDrawImage(context, imageRect, image.CGImage)
        
        CGContextClipToMask(context, imageRect, image.CGImage)
        CGContextAddRect(context, imageRect)
        CGContextDrawPath(context, kCGPathFill)
    }
}



extension UIImage {
    public func imageRotatedByDegrees(degrees: Double, flip: Bool) -> UIImage {
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(CGFloat(toRadian(degrees)));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, CGFloat(toRadian(degrees)));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func resizeImage(newSize:CGSize) -> UIImage {
        var newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        var imageRef:CGImageRef = self.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.mainScreen().scale)
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
    
    func cropHeight(offset:CGFloat) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: self.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        var posX:CGFloat = 0
        var posY:CGFloat = offset
        var width:CGFloat = contextSize.width
        var height:CGFloat = contextSize.height - offset
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)!
        
        return image
    }
}
