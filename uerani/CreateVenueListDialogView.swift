//
//  CreateVenueListDialogView.swift
//  uerani
//
//  Created by nacho on 9/19/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class CreateVenueListDialogView : UIView {
    
    var headerView:VenueListDialogHeaderView
    var buttonBarView:VenueListDialogButtonBarView
    var venueListNameText:BorderedTextField
    var textParentView:UIView
    
    var okAction:CloseDialogAction? {
        didSet {
            self.buttonBarView.okAction = self.okAction
        }
    }
    
    var cancelAction:CloseDialogAction? {
        didSet {
            self.buttonBarView.cancelAction = self.cancelAction
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        let headerFrame = CGRectMake(0, 0, frame.width, 35.0);
        self.headerView = VenueListDialogHeaderView(frame: headerFrame)
        self.headerView.title = "Create List"
        
        let buttonsFrame = CGRectMake(0, frame.size.height - 40, frame.size.width, 45)
        self.buttonBarView = VenueListDialogButtonBarView(frame: buttonsFrame)
        
        let textFrame = CGRectMake(0, 35.0, frame.width, frame.size.height - (headerFrame.size.height + buttonsFrame.size.height - 5))
        self.textParentView = UIView(frame: textFrame)
        
        self.venueListNameText = BorderedTextField(frame: CGRectMake(5, 5, textFrame.size.width - 10, textFrame.size.height - 10))
        
        self.venueListNameText.placeholder = "Name"
        
        super.init(frame: frame)
        self.layer.cornerRadius = 6.0
        self.backgroundColor = UIColor.blackColor()
    }
    
    public override func didMoveToSuperview() {
        self.addSubview(self.headerView)
        self.addSubview(self.buttonBarView)
        self.textParentView.addSubview(self.venueListNameText)
        self.addSubview(self.textParentView)
    }
}