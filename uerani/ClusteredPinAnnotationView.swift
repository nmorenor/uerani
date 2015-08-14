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
        if let annotation = annotation as? FBAnnotationCluster {
            let number = annotation.annotations.count
            
            let fontSize:CGFloat = number > 9 ? 20 : 15
            var font = UIFont(name: "HelveticaNeue", size: fontSize)!
            var yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
            var attributedString = NSAttributedString(string: String(annotation.annotations.count), attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: yellowColor])
            let asize:CGSize = attributedString.size()
            let size = max((asize.width + 5), 30)
            
            let label = CATextLayer()
            label.frame = CGRectMake(2.5, ((((size - 2.5) - fontSize) / 2) + 2.5), size, size)
            label.alignmentMode = kCAAlignmentCenter
            label.allowsEdgeAntialiasing = true
            label.string = attributedString
            label.backgroundColor = UIColor.clearColor().CGColor
            label.foregroundColor = yellowColor.CGColor
            label.zPosition = 0
            label.contentsScale = UIScreen.mainScreen().scale
            
            let backCircle = CAShapeLayer()
            backCircle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, size + 5, size + 5)).CGPath
            backCircle.fillColor = yellowColor.CGColor
            backCircle.backgroundColor = UIColor.clearColor().CGColor
            
            let circle = CAShapeLayer()
            circle.path = UIBezierPath(ovalInRect: CGRectMake(2.5, 2.5, size, size)).CGPath
            circle.fillColor = UIColor.blackColor().CGColor
            circle.backgroundColor = UIColor.clearColor().CGColor
            backCircle.addSublayer(circle)
            circle.addSublayer(label)
            
            layer.addSublayer(backCircle)
        }
    }
}
