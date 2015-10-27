//
//  VenueDetailView.swift
//  uerani
//
//  Created by nacho on 9/11/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

protocol VenueDetailAccessoryDelegate : class {
    
    func handleAccessoryTouch()
}

class VenueDetailView: UIView {
    
    let imageLayer = CALayer()
    let textLayer = CATextLayer()
    let borderLayer = CALayer()
    let accessoryLayer = CALayer()
    let fontName = "HelveticaNeue"
    var accessoryDelegate:VenueDetailAccessoryDelegate?
    
    var image:UIImage? {
        didSet {
            self.imageLayer.removeFromSuperlayer()
            if let image = self.image {
                imageLayer.contents = image.CGImage
                layer.addSublayer(imageLayer)
            } else {
                imageLayer.contents = nil
            }
        }
    }
    
    var accessoryImage:UIImage? {
        didSet {
            self.accessoryLayer.removeFromSuperlayer()
            if let image = self.accessoryImage {
                accessoryLayer.contents = image.CGImage
                layer.addSublayer(accessoryLayer)
            } else {
                accessoryLayer.contents = nil
            }
        }
    }
    
    var text:String!
    
    required init?(coder aDecoder: NSCoder) {
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
        
        layer.addSublayer(textLayer)
        layer.addSublayer(borderLayer)
    }
    
    override func layoutSubviews() {
        self.textLayer.wrapped = true
        if let image = image, let accessoryImage = self.accessoryImage {
            let imageRect = CGRectMake(10, (self.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height)
            self.imageLayer.frame = imageRect
            
            let textSize = calculateSizeForText(self.frame.width - (self.imageLayer.frame.size.width + 20 + accessoryImage.size.width + 25), attributedString: getAttributedString())
            
            self.textLayer.frame = CGRectMake(self.imageLayer.frame.size.width + 20, (self.frame.size.height/2) - (textSize.height/2), self.frame.width - ((self.imageLayer.frame.size.width + 20) + accessoryImage.size.width + 25), self.frame.size.height)
            
            self.accessoryLayer.frame = CGRectMake((self.imageLayer.frame.size.width + 20) + (self.textLayer.frame.size.width + 5), (self.frame.size.height/2) - (accessoryImage.size.height/2), accessoryImage.size.width, accessoryImage.size.height)
        } else if let image = image {
            let imageRect = CGRectMake(10, (self.frame.size.height/2) - (image.size.height/2), image.size.width, image.size.height)
            self.imageLayer.frame = imageRect
            
            let textSize = calculateSizeForText(self.frame.width - (self.imageLayer.frame.size.width + 20), attributedString: getAttributedString())
            
            self.textLayer.frame = CGRectMake(self.imageLayer.frame.size.width + 20, (self.frame.size.height/2) - (textSize.height/2), self.frame.width - (self.imageLayer.frame.size.width + 20), self.frame.size.height)
        } else {
            let textSize = calculateSizeForText(self.frame.width - 20, attributedString: getAttributedString())
            
            self.textLayer.frame = CGRectMake(10, (self.frame.size.height/2) - (textSize.height/2), self.frame.width - 20, self.frame.size.height)
        }
        self.textLayer.string = getAttributedString()
        
        borderLayer.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)
        borderLayer.backgroundColor = UIColor.ueraniDarkYellowColor().CGColor
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = self.accessoryImage {
            let touch = touches.first! 
            let p:CGPoint = touch.locationInView(self)
            if self.accessoryLayer.containsPoint(self.layer.convertPoint(p, toLayer: self.accessoryLayer)) {
                self.accessoryDelegate?.handleAccessoryTouch()
            }
        }
    }
    
    func getAttributedString() -> NSAttributedString {
        let fontName = "HelveticaNeue"
        let font = UIFont(name: fontName, size: 14.0)!
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        let attributedString = NSAttributedString(string: self.text, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName : paraStyle])
        return attributedString
    }
}

extension UIView {
    func calculateSizeForText(width:CGFloat, attributedString:NSAttributedString) -> CGSize {
        let stringRef = attributedString as CFAttributedStringRef
        
        let typesetter = CTTypesetterCreateWithAttributedString(stringRef)
        
        var offset:CFIndex = 0
        var length:CFIndex = 0
        var y:CGFloat = 0
        repeat {
            length = CTTypesetterSuggestLineBreak(typesetter, offset, Double(width))
            let line:CTLineRef = CTTypesetterCreateLine(typesetter, CFRangeMake(offset, length))
            
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
