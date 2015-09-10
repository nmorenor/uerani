//
//  VenueRatingView.swift
//  uerani
//
//  Created by nacho on 9/9/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

@IBDesignable
class VenueRatingView : UIView {
    
    let squareLayer = CAShapeLayer()
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 22.0)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
        }()
    
    @IBInspectable
    var rating: String? {
        didSet {
            label.text = rating
        }
    }
    
    override func didMoveToWindow() {
        layer.addSublayer(squareLayer)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        squareLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).CGPath
        squareLayer.strokeColor = UIColor.whiteColor().CGColor
        squareLayer.lineWidth = 3.5
        squareLayer.fillColor = UIColor.blackColor().CGColor
        
        label.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
    }

}
