//
//  BorderedTextField.swift
//  On The Map
//
//  Created by nacho on 4/20/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

let borderedTextCornerRadius : CGFloat = 2.0

class BorderedTextField : UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = borderedTextCornerRadius;
        self.textColor = UIColor.blackColor()
        self.backgroundColor = nil
        self.font = UIFont(name: "HelveticaNeue", size: 17.0)
        let paddingView = UIView(frame: CGRectMake(0, 0, 5, 20))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.Always
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = borderedTextCornerRadius;
        self.textColor = UIColor.blackColor()
        self.backgroundColor = nil
        self.font = UIFont(name: "HelveticaNeue", size: 17.0)
        let paddingView = UIView(frame: CGRectMake(0, 0, 5, 20))
        self.leftView = paddingView
        self.leftViewMode = UITextFieldViewMode.Always
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext();
        let white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor;
        CGContextSetFillColorWithColor(context, white);
        CGContextFillRect(context, self.bounds);
    }

    override func awakeFromNib() {
        let attributes = self.attributedPlaceholder?.attributesAtIndex(0, effectiveRange: nil) as NSDictionary?
        
        var newAttributes:NSMutableDictionary = NSMutableDictionary(dictionary: attributes!)
        newAttributes.setObject(UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
        
        self.attributedPlaceholder = NSAttributedString(string: self.attributedPlaceholder!.string, attributes: newAttributes as [NSObject : AnyObject])
    }
}
