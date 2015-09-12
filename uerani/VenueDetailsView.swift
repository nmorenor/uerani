//
//  VenueDetailsView.swift
//  uerani
//
//  Created by nacho on 9/11/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class VenueDetailsView : UIView {
    
    var locationView:VenueDetailView? {
        didSet {
            if let locationView = self.locationView {
                self.addSubview(locationView)
            }
        }
    }
    var locationViewBorder:CALayer?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        if let locationView = self.locationView {
            var size = self.calculateSizeForText(self.frame.size.width - 20, text: locationView.text, attributedString: self.getAttributedString(locationView.text))
            locationView.frame = CGRectMake(10, 0, self.frame.size.width - 20, size.height)
            locationView.layoutSubviews()
            
            if self.locationViewBorder == nil {
                locationViewBorder = CALayer()
                layer.addSublayer(self.locationViewBorder!)
            }
            locationViewBorder!.frame = CGRectMake(0, size.height + 3, self.frame.size.width, 1)
            locationViewBorder!.backgroundColor = UIColor.blackColor().CGColor
        }
    }
    
    func getAttributedString(text:String) -> NSAttributedString {
        let fontName = "HelveticaNeue"
        var font = UIFont(name: fontName, size: 14.0)!
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        var attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName : paraStyle])
        return attributedString
    }
}