//
//  BorderedButton.swift
//  On The Map
//
//  Created by nacho on 4/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import QuartzCore

let borderedButtonCornerRadius : CGFloat = 20.0

class FSButton: UIButton {
    
    // MARK: - Properties
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    var borderColor:UIColor? {
        didSet {
            layer.borderWidth = 4.0
            layer.borderColor = self.borderColor!.CGColor
        }
    }
    
    // MARK: - Constructors
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = borderedButtonCornerRadius;
        
        var image = UIImage(named: "foursquare-word-mark")
        image = image!.resizeImage(CGSizeMake(image!.size.width / 12, image!.size.height / 12))
        image = image!.imageRotatedByDegrees(-90.0, flip: false)
        image = image!.cropHeight(45)
        
        self.setImage(image!, forState: UIControlState.allZeros)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Setters
    
    private func setBackingColor(backingColor : UIColor) -> Void {
        if (self.backingColor != nil) {
            self.backingColor = backingColor;
            self.backgroundColor = backingColor;
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.layer.shouldRasterize = true
        self.imageView?.layer.edgeAntialiasingMask = CAEdgeAntialiasingMask.LayerLeftEdge | .LayerRightEdge | .LayerBottomEdge | CAEdgeAntialiasingMask.LayerTopEdge
        self.imageView?.clipsToBounds = false
        self.imageView?.layer.masksToBounds = false
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var frame:CGRect = super.imageRectForContentRect(contentRect)
        frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) -  self.imageEdgeInsets.right + self.imageEdgeInsets.left;
        frame.origin.y = contentRect.size.height / 2 - (contentRect.size.height / 9)

        return frame;
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var frame:CGRect = super.titleRectForContentRect(contentRect)
        frame.origin.x = (CGRectGetMinX(frame) + 9) - CGRectGetWidth(self.imageRectForContentRect(contentRect))
        return frame
    }
    
    private func setHighlightedBackingColor(highlightedBackingColor: UIColor) -> Void {
        self.highlightedBackingColor = highlightedBackingColor
        self.backingColor = highlightedBackingColor
    }
    
    // MARK: - Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent: UIEvent) -> Bool {
        self.backgroundColor = self.highlightedBackingColor
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent: UIEvent) {
        self.backgroundColor = self.backingColor
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        self.backgroundColor = self.backingColor
    }
}
