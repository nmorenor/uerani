//
//  FoursquareAnnotationVenueInformationView.swift
//  uerani
//
//  Created by nacho on 8/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import QuartzCore

class FoursquareAnnotationVenueInformationView: UIView {

    let lineWidth: CGFloat = 6.0
    //ui
    let photoLayer = CALayer()
    let circleLayer = CAShapeLayer()
    let innerCircleLayer = CAShapeLayer()
    let maskLayer = CAShapeLayer()
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 11.0)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = UIColor.whiteColor()
        return label
        }()
    let addressLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 11.0)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = UIColor.whiteColor()
        label.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        label.numberOfLines = 0
        return label
        }()
    
    var isSquare = false
    
    var image: UIImage! {
        didSet {
            photoLayer.contents = image.CGImage
        }
    }
    
    var name: String? {
        didSet {
            label.text = name
        }
    }
    
    var address:String? {
        didSet {
            addressLabel.text = address
        }
    }
    
    override func didMoveToWindow() {
        photoLayer.mask = maskLayer
        
        layer.addSublayer(circleLayer)
        layer.addSublayer(photoLayer)
        
        addSubview(label)
        addSubview(addressLabel)
    }
    
    override func layoutSubviews() {
        //Size the avatar image to fit
        photoLayer.hidden = true
        circleLayer.hidden = true
        photoLayer.frame = CGRect(
            x: 2.5,
            y: 0,
            width: image.size.width,
            height: image.size.height)
        
        
        var yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
        //Draw the circle
        
        circleLayer.frame.size = photoLayer.frame.size
        circleLayer.path = UIBezierPath(ovalInRect: photoLayer.bounds).CGPath
        circleLayer.strokeColor = UIColor.clearColor().CGColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = yellowColor.CGColor
        circleLayer.frame.origin = photoLayer.frame.origin
        
        innerCircleLayer.path = UIBezierPath(ovalInRect: CGRectMake(5, 5, photoLayer.bounds.size.width - 10, photoLayer.bounds.size.height - 10)).CGPath
        innerCircleLayer.strokeColor = UIColor.blackColor().CGColor
        innerCircleLayer.lineWidth = lineWidth
        innerCircleLayer.fillColor = UIColor.blackColor().CGColor
        
        circleLayer.addSublayer(self.innerCircleLayer)
        
        //Size the layer
        maskLayer.path = circleLayer.path
        maskLayer.position = CGPoint(x: 0.0, y: 10.0)
        
        //Size the label
        label.frame = CGRect(x: photoLayer.bounds.size.width + 9, y: 0, width: (self.frame.size.width - 64) - photoLayer.bounds.size.width, height: 15.0)
        addressLabel.frame = CGRect(x: photoLayer.bounds.size.width + 6, y: 15, width: (self.frame.size.width - 64) - photoLayer.bounds.size.width, height: self.frame.size.height - 22)
        
        animateSize(photoLayer)
        animateSize(circleLayer)
    }
    
    func animateSize(layer:CALayer) {
        var animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.3
        
        layer.addAnimation(animation, forKey: nil)
        layer.hidden = false
    }
}
