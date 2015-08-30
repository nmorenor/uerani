//
//  UserViewTop.swift
//  uerani
//
//  Created by nacho on 8/29/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public class UserViewTop : UIView {
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    public override func drawRect(rect: CGRect) {
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        UIColor.blackColor().setFill()
        var path:CGMutablePathRef = CGPathCreateMutable()
        CGContextSetLineWidth(context, 0.0)
        
        let arcHeight:CGFloat = rect.size.height * 0.20
        let bottomHeight:CGFloat = rect.size.height - arcHeight
        
        CGPathMoveToPoint(path, nil, rect.size.width, rect.origin.y)
        CGPathAddLineToPoint(path, nil, 0, 0)
        
        createArcPathOnBottomOfRect(rect, arcHeight: arcHeight * 0.95, path: path)
        CGPathCloseSubpath(path)
        
        CGContextAddPath(context, path)
        
        CGContextSaveGState(context)
        CGContextDrawPath(context, kCGPathFill);
        CGContextRestoreGState(context)
    }
    
    private func createArcPathOnBottomOfRect(rect:CGRect, arcHeight:CGFloat, path:CGMutablePathRef) {
        var arcRect:CGRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight)
    
        var arcRadius:CGFloat = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height))
        // if we want to set the arc upside increment y point -> arcRect.origin.y + arcRadius
        var arcCenter:CGPoint  = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y - arcRadius)
    
        var angle:CGFloat = acos(arcRect.size.width / (2*arcRadius))
        var startAngle:CGFloat = (CGFloat(toRadian(180)) + angle)
        var endAngle:CGFloat = (CGFloat(toRadian(360)) - angle)
        
        CGPathAddArc(path, nil, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, true)
    }
}