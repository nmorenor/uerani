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

public class VenueListsViewController : UITableViewController, DialogOKDelegate {
    
    var venueListTableDelegate:VenueToListTableDelegate!
    var createVenueListController:CreateVenueListController?
    //MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "handleAddList:")
        self.venueListTableDelegate = VenueToListTableDelegate(tableView: self.tableView, cellIdentifier:"VenueListCell")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.venueListTableDelegate.venueListSelectionAction = self.venueSelected
        self.venueListTableDelegate.selectAccessory = false
        self.tableView.dataSource = self.venueListTableDelegate
        self.tableView.delegate = self.venueListTableDelegate
    }
    
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    func handleAddList(button:UIBarButtonItem) {
        self.createVenueListController = CreateVenueListController()
        self.createVenueListController?.addCloseAction(self.closeDialog)
        self.createVenueListController?.dialogOKDelegate = self
        self.createVenueListController?.show(self)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func venueSelected() {
        let venuesOfListController = self.storyboard?.instantiateViewControllerWithIdentifier("VenuesOfListViewController") as! VenuesFromListViewController
        venuesOfListController.list = self.venueListTableDelegate.selectedList!
        self.navigationController?.pushViewController(venuesOfListController, animated: true)
    }
    
    func closeDialog() {
        self.createVenueListController = nil
    }
    
    public func performOK(data:String) {
        dispatch_async(dispatch_get_main_queue()) {
            let request = NSFetchRequest(entityName: "CDUser")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.predicate = NSPredicate(format: "id == %@", FoursquareClient.sharedInstance().userId!)
        
            var error:NSError? = nil
            var cResult: [AnyObject]?
            do {
                cResult = try self.sharedContext.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                cResult = nil
            } catch {
                fatalError()
            }
            if let error = error {
                if DEBUG {
                    print("*** \(String(UserViewModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not load user data from core data: \(error)")
                }
            } else if let result = cResult where result.count > 0 {
                let user = result.first! as! CDUser
                _ = CDVenueList(title: data, user: user, context: self.sharedContext)
                saveContext(self.sharedContext) { _ in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.venueListTableDelegate.reload()
                    }
                }
            }
        }
    }
}
