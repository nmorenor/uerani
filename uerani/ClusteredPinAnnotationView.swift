//
//  ClusteredPinAnnotationView.swift
//  uerani
//
//  Created by nacho on 8/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MapKit
import FBAnnotationClustering

class ClusteredPinAnnotationView : MKAnnotationView {
    
    override var annotation: MKAnnotation! {
        didSet {
             if let annotation = annotation as? FBAnnotationCluster where annotation.annotations.count != self.currentCount {
                self.prepareFrameSize()
                self.currentCount = annotation.annotations.count
                self.setNeedsDisplay()
            }
        }
    }
    
    let fontName = "HelveticaNeue"
    var label:CATextLayer = CATextLayer()
    let yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    var initalized:Bool = false
    var currentCount:Int = -1
    
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
        if let annotation = annotation as? FBAnnotationCluster {
            let number = annotation.annotations.count
            
            let fontSize:CGFloat = self.getFontSize(number)
            var font = UIFont(name: fontName, size: fontSize)!
            var attributedString = NSAttributedString(string: String(annotation.annotations.count), attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: yellowColor])
            let asize:CGSize = attributedString.size()
            let size = asize.width + 16
            self.frame = CGRectMake(0, 0, size + 8, size + 8)
        }
    }
    
    override func drawRect(rect: CGRect) {
        if let annotation = annotation as? FBAnnotationCluster {
            let size = self.frame.size.width
            let number = annotation.annotations.count
            let fontSize:CGFloat = self.getFontSize(annotation.annotations.count)
            
            var context:CGContextRef = UIGraphicsGetCurrentContext();
            
            CGContextSetLineWidth(context, 6); // set the line width
            yellowColor.setStroke()
            
            var center:CGPoint = CGPointMake(size/2, size/2)
            var radius:CGFloat = 0.80 * center.x;
            var startAngle:CGFloat = -(CGFloat(M_PI) / 2); // 90 degrees
            var endAngle:CGFloat = ((2 * CGFloat(M_PI)) + startAngle);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            
            CGContextStrokePath(context);
            
            CGContextSetLineWidth(context, 0);
            center = CGPointMake(size/2, size/2)
            startAngle = -(CGFloat(M_PI) / 2); // 90 degrees
            endAngle = ((2 * CGFloat(M_PI)) + startAngle);
            CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
            
            UIColor.blackColor().setFill()
            
            CGContextSaveGState(context)
            CGContextFillPath(context)
            CGContextRestoreGState(context)
            
            var textStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
            textStyle.alignment = NSTextAlignment.Center
            
            var font = UIFont(name: fontName, size: fontSize)!
            
            CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect))
            CGContextScaleCTM(context, 1.0, -1.0)
            let attr:CFDictionaryRef = [NSFontAttributeName:font,NSForegroundColorAttributeName:yellowColor]
            // create the attributed string
            let text = CFAttributedStringCreate(nil, "\(number)", attr)
            // create the line of text
            let line = CTLineCreateWithAttributedString(text)
            // retrieve the bounds of the text
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            // set the line width to stroke the text with
            CGContextSetLineWidth(context, 1.5)
            // set the drawing mode to stroke
            CGContextSetTextDrawingMode(context, kCGTextFill)
            
            CGContextSetTextPosition(context, (center.x - (bounds.size.width/2)), (((bounds.size.height/2) + (center.y / 2)) - (((bounds.size.height/2) - (radius/2)))) - 4)
            // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
            // draw the line of text
            CTLineDraw(line, context)
        }
    }
    
    private func getFontSize(number:Int) -> CGFloat {
        return number > 9 ? 20 : 18
    }
}
