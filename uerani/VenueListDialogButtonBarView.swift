//
//  VenueListDialogButtonBarView.swift
//  uerani
//
//  Created by nacho on 9/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public typealias CloseDialogAction = ((Bool)->Void)

public class VenueListDialogButtonBarView : UIView {
    
    var okButton:BorderedButton
    var cancelButton:BorderedButton
    var closeAction:CloseDialogAction?
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        var cancelButtonFrame = CGRectMake(10, 5, (frame.width/2) - 20, frame.size.height - 10)
        var okButtonFrame = CGRectMake((frame.width/2) + 10, 5, (frame.width/2) - 20, frame.size.height - 10)
        self.okButton = BorderedButton(frame: okButtonFrame)
        self.cancelButton = BorderedButton(frame: cancelButtonFrame)
        super.init(frame: frame)
        self.backgroundColor = UIColor.ueraniDarkYellowColor()
        
        self.okButton.addTarget(self, action: "handleClose:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelButton.addTarget(self, action: "handleClose:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func handleClose(button:BorderedButton) {
        self.closeAction?(true)
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
        button.layer.cornerRadius = 6.0
    }
}
