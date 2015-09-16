//
//  VenueListDialogButtonBarView.swift
//  uerani
//
//  Created by nacho on 9/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class VenueListDialogButtonBarView : UIView {
    
    var okButton:BorderedButton
    var cancelButton:BorderedButton
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        var cancelButtonFrame = CGRectMake(0, 5, (frame.width/2) - 40, frame.size.height)
        var okButtonFrame = CGRectMake((frame.width/2) + 30, 5, (frame.width/2) - 40, frame.size.height)
        self.okButton = BorderedButton(frame: okButtonFrame)
        self.cancelButton = BorderedButton(frame: cancelButtonFrame)
        super.init(frame: frame)
        self.backgroundColor = UIColor.ueraniYellowColor()
    }
    
    public override func didMoveToSuperview() {
        self.configureButton(cancelButton)
        self.configureButton(okButton)
        
        cancelButton.setTitle("Cancel", forState: UIControlState.allZeros)
        okButton.setTitle("Ok", forState: UIControlState.allZeros)
        
        self.addSubview(cancelButton)
        self.addSubview(okButton)
    }
    
    private func configureButton(button:BorderedButton) {
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 1.5
        button.highlightedBackingColor = UIColor.ueraniBlackJetColor()
        button.backingColor = UIColor.blackColor()
        button.backgroundColor = UIColor.blackColor()
    }
}
