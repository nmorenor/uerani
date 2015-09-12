//
//  VenueDetailView.swift
//  uerani
//
//  Created by nacho on 9/11/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class VenueDetailView: UIView {
    
    let imageLayer = CALayer()
    let textLayer = CATextLayer()
    let borderLayer = CALayer()
    let fontName = "HelveticaNeue"
    
    var image:UIImage? {
        didSet {
            if let image = self.image {
                imageLayer.contents = image.CGImage
            } else {
                imageLayer.contents = nil
            }
        }
    }
    
    var text:String!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func didMoveToWindow() {
        imageLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.contentsScale = UIScreen.mainScreen().scale
        borderLayer.contentsScale = UIScreen.mainScreen().scale
        
        if let image = self.image {
            layer.addSublayer(imageLayer)
        }
        
        layer.addSublayer(textLayer)
        layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        if let image = image {
            var imageRect = CGRectMake(0, (self.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.width)
            self.imageLayer.frame = imageRect
            self.textLayer.frame = CGRectMake(image.size.width + 8, 0, self.frame.width - 8, self.frame.size.height)
        } else {
            self.textLayer.frame = CGRectMake(0, 0, self.frame.width, self.frame.size.height)
        }
        self.textLayer.string = getAttributedString()
        
        
    }
    
    func getAttributedString() -> NSAttributedString {
        let fontName = "HelveticaNeue"
        var font = UIFont(name: fontName, size: 14.0)!
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        var attributedString = NSAttributedString(string: self.text, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName : paraStyle])
        return attributedString
    }
}

extension UIView {
    func calculateSizeForText(width:CGFloat, text:String, attributedString:NSAttributedString) -> CGSize {
        var stringRef = attributedString as CFAttributedStringRef
        
        var typesetter = CTTypesetterCreateWithAttributedString(stringRef)
        
        var offset:CFIndex = 0
        var length:CFIndex = 0
        var y:CGFloat = 0
        do {
            length = CTTypesetterSuggestLineBreak(typesetter, offset, Double(width))
            var line:CTLineRef = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length))
            
            var ascent:CGFloat = 0
            var descent:CGFloat = 0
            var leading:CGFloat = 0
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            
            offset += length;
            y += ascent + descent + leading
        } while (offset < attributedString.length)
        
        return CGSizeMake(width, ceil(y))
    }
}
