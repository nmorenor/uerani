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
    var okAction:CloseDialogAction?
    var cancelAction:CloseDialogAction?
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        let cancelButtonFrame = CGRectMake(10, 5, (frame.width/2) - 20, frame.size.height - 10)
        let okButtonFrame = CGRectMake((frame.width/2) + 10, 5, (frame.width/2) - 20, frame.size.height - 10)
        self.okButton = BorderedButton(frame: okButtonFrame)
        self.cancelButton = BorderedButton(frame: cancelButtonFrame)
        super.init(frame: frame)
        self.backgroundColor = UIColor.ueraniDarkYellowColor()
        
        self.okButton.addTarget(self, action: "handleOK:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelButton.addTarget(self, action: "handleCancel:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func handleOK(button:BorderedButton) {
        self.okAction?(true)
    }
    
    func handleCancel(button:BorderedButton) {
        self.cancelAction?(true)
    }
    
    public override func didMoveToSuperview() {
        self.configureButton(cancelButton)
        self.configureButton(okButton)
        
        cancelButton.setTitle("Cancel", forState: UIControlState())
        okButton.setTitle("Ok", forState: UIControlState())
        
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
