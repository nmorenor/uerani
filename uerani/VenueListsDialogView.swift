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
        var headerFrame = CGRectMake(0, 0, frame.width, 24.0);
        self.headerView = VenueListDialogHeaderView(frame: headerFrame)
        self.headerView.title = "Add Venue To List"
        
        var buttonsFrame = CGRectMake(0, frame.size.height - 40, frame.size.width, 30)
        self.buttonBarView = VenueListDialogButtonBarView(frame: buttonsFrame)
        
        var tableFrame = CGRectMake(0, 24.0, frame.width, frame.size.height - (headerFrame.size.height + buttonsFrame.size.height))
        self.tableView = UITableView(frame: tableFrame)
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
    }
    
    public override func didMoveToSuperview() {
        self.addSubview(self.headerView)
        self.addSubview(self.tableView)
        self.addSubview(self.buttonBarView)
    }
}
