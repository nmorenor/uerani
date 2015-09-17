//
//  VenueListsDialogView.swift
//  uerani
//
//  Created by nacho on 9/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class VenueListsDialogView : UIView {
    
    var headerView:VenueListDialogHeaderView
    var buttonBarView:VenueListDialogButtonBarView
    var tableView:UITableView
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        var headerFrame = CGRectMake(0, 0, frame.width, 35.0);
        self.headerView = VenueListDialogHeaderView(frame: headerFrame)
        self.headerView.title = "Add Venue To List"
        
        var buttonsFrame = CGRectMake(0, frame.size.height - 40, frame.size.width, 45)
        self.buttonBarView = VenueListDialogButtonBarView(frame: buttonsFrame)
        
        var tableFrame = CGRectMake(0, 35.0, frame.width, frame.size.height - (headerFrame.size.height + buttonsFrame.size.height - 5))
        self.tableView = UITableView(frame: tableFrame)
        
        super.init(frame: frame)
        self.layer.cornerRadius = 6.0
        self.backgroundColor = UIColor.blackColor()
    }
    
    public override func didMoveToSuperview() {
        self.addSubview(self.headerView)
        self.addSubview(self.buttonBarView)
        self.addSubview(self.tableView)
    }
}
