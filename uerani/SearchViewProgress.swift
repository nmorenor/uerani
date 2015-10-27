//
//  SearchViewProgress.swift
//  uerani
//
//  Created by nacho on 8/11/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import QuartzCore

class SearchViewProgress: UIView {

    var ovalShapeLayer:CAShapeLayer = CAShapeLayer()
    var currentProgress:CGFloat = 0.0
    let max:CGFloat = 1.0
    let min:CGFloat = 0.0
    let increment:CGFloat = 0.7
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        self.ovalShapeLayer.strokeColor = UIColor.whiteColor().CGColor
        self.ovalShapeLayer.fillColor = UIColor.clearColor().CGColor
        self.ovalShapeLayer.lineWidth = 4.0
        self.ovalShapeLayer.lineDashPattern = [2, 3]
        let refreshRadius = frame.size.height/2 * 0.8
        
        self.ovalShapeLayer.path = UIBezierPath(ovalInRect: CGRect(
            x: frame.size.width/2 - (refreshRadius + 4),
            y: frame.size.height/2 - (refreshRadius),
            width: 2 * refreshRadius,
            height: 2 * refreshRadius)
            ).CGPath
        self.backgroundColor = UIColor.blackColor()
        self.layer.addSublayer(ovalShapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beginProgress() {
        self.ovalShapeLayer.needsDisplay()
        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.fromValue = -0.5
        strokeStartAnimation.toValue = 1.0
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = 1.5
        strokeAnimationGroup.repeatDuration = .infinity
        strokeAnimationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
        self.ovalShapeLayer.addAnimation(strokeAnimationGroup, forKey: nil)
    }
    
    func endProgress() {
        self.ovalShapeLayer.removeAllAnimations()
    }
    
    func redrawFromProgress() {
        ovalShapeLayer.strokeEnd = self.currentProgress
    }
    
}
