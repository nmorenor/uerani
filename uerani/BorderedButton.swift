//
//  BorderedButton.swift
//  On The Map
//
//  Created by nacho on 4/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit

let borderedButtonHeight : CGFloat = 44.0
let borderedButtonCornerRadius : CGFloat = 4.0
let padBorderedButtonExtraPadding : CGFloat = 20.0
let phoneBorderedButtonExtraPadding : CGFloat = 14.0

class BorderedButton: UIButton {
    
    // MARK: - Properties
    
    var backingColor : UIColor? = nil
    var highlightedBackingColor : UIColor? = nil
    
    // MARK: - Constructors
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = borderedButtonCornerRadius;
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
    
    // MARK: - Layout
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let userInterfaceIdiom = UIDevice.currentDevice().userInterfaceIdiom
        let extraButtonPadding : CGFloat = 14.0
        var sizeThatFits = CGSizeZero
        sizeThatFits.width = super.sizeThatFits(size).width + extraButtonPadding
        sizeThatFits.height = 44.0
        return sizeThatFits
        
    }
}
