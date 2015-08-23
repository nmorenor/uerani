//
//  ImageUtils.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

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
    
    func imageWithColor(color: UIColor) -> UIImage? {
        // begin a new image context, to draw our colored image onto. Passing in zero for scale tells the system to take from the current device's screen scale.
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        
        // get a reference to that context we created
        let context = UIGraphicsGetCurrentContext()
        
        // set the context's fill color
        color.setFill()
    
        // translate/flip the graphics context (for transforming from CoreGraphics coordinates to default UI coordinates. The Y axis is flipped on regular coordinate systems)
        CGContextTranslateCTM(context, 0.0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let rect = CGRect(origin: CGPointZero, size: self.size)
        CGContextDrawImage(context, rect, self.CGImage)
        
        // set a mask that matches the rect of the image, then draw the color burned context path.
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextAddRect(context, rect)
        CGContextDrawPath(context, kCGPathFill)
        
        // generate a new UIImage from the graphics context we've been drawing onto
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}