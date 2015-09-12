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
        willSet (value) {
            if value == nil {
                self.locationView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let locationView = self.locationView {
                self.addSubview(locationView)
            }
        }
    }
    
    var phoneView:VenueDetailView? {
        willSet (value) {
            if value == nil {
                self.phoneView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let phoneView = self.phoneView {
                self.addSubview(phoneView)
            }
        }
    }
    
    var mailView:VenueDetailView? {
        willSet (value) {
            if value == nil {
                self.mailView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let mailView = self.mailView {
                self.addSubview(mailView)
            }
        }
    }
    
    var hoursView:VenueDetailView? {
        willSet (value) {
            if value == nil {
                self.hoursView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let hoursView = self.hoursView {
                self.addSubview(hoursView)
            }
        }
    }
    
    var descriptionView:VenueDetailView? {
        willSet (value) {
            if value == nil {
                self.descriptionView?.removeFromSuperview()
            }
        }
        
        didSet {
            if let descriptionView = self.descriptionView {
                self.addSubview(descriptionView)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        var nextPoint:CGPoint = CGPointMake(0, 0)
        for next in self.subviews {
            if let detailView = next as? VenueDetailView {
                nextPoint = self.setupDetailViewLayout(detailView, point:nextPoint)
            }
        }
    }
    
    private func setupDetailViewLayout(view:VenueDetailView, point:CGPoint) -> CGPoint {
        var size = self.calculateSizeForText(self.frame.size.width - 20, attributedString: view.getAttributedString())
        if let image = view.image where image.size.height > size.height {
            size = CGSizeMake(size.width, image.size.height)
        }
        view.frame = CGRectMake(0, point.y, self.frame.size.width, size.height + 20)
        view.layoutSubviews()
        
        return CGPointMake(point.x, (point.y + size.height + 20))
    }
}