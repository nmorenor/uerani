//
//  VenueListsViewController.swift
//  uerani
//
//  Created by nacho on 9/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class VenueListsViewController : UITableViewController {
    
    var venueListTableDelegate:VenueToListTableDelegate!
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.venueListTableDelegate = VenueToListTableDelegate(tableView: self.tableView, cellIdentifier:"VenueListCell")
        self.venueListTableDelegate.venueListSelectionAction = self.venueSelected
        self.venueListTableDelegate.selectAccessory = false
        self.tableView.dataSource = self.venueListTableDelegate
        self.tableView.delegate = self.venueListTableDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func venueSelected() {
        var venuesOfListController = self.storyboard?.instantiateViewControllerWithIdentifier("VenuesOfListViewController") as! VenuesFromListViewController
        venuesOfListController.list = self.venueListTableDelegate.selectedList!
        self.navigationController?.pushViewController(venuesOfListController, animated: true)
    }
}
