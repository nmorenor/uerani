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
    var tableDataSource:VenueToListTableDelegate
    
    var selectedList:CDVenueList? {
        get {
            return self.tableDataSource.selectedList
        }
    }
    
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
        self.headerView.title = "Add Venue To List"
        
        let buttonsFrame = CGRectMake(0, frame.size.height - 40, frame.size.width, 45)
        self.buttonBarView = VenueListDialogButtonBarView(frame: buttonsFrame)
        
        let tableFrame = CGRectMake(0, 35.0, frame.width, frame.size.height - (headerFrame.size.height + buttonsFrame.size.height - 5))
        self.tableView = UITableView(frame: tableFrame)
        self.tableDataSource = VenueToListTableDelegate(tableView: self.tableView, cellIdentifier:"venueListCell")
        self.tableView.dataSource = self.tableDataSource
        self.tableView.delegate = self.tableDataSource
        
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
