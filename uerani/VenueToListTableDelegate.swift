//
//  VenueToListTableDelegate.swift
//  uerani
//
//  Created by nacho on 9/17/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public typealias VenueListSelectionAction = (()->Void)

public class VenueToListTableDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var tableView:UITableView
    var cellIdentifier:String
    var venueListSelectionAction:VenueListSelectionAction?
    var selectAccessory:Bool = true
    weak var selectedList:CDVenueList?
    
    init(tableView:UITableView, cellIdentifier:String) {
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        super.init()
        
        self.reload()
    }
    
    func reload() {
        var error:NSError? = nil
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let _ = error {
            if DEBUG {
                print("Error performing initial fetch")
            }
        }
        let sectionInfo = self.fetchedResultsController.sections!.first
        if sectionInfo!.numberOfObjects > 0 {
            self.tableView.reloadData()
        }
    }
    
    // MARK - Core Data
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "CDVenueList")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "user.id == %@", FoursquareClient.sharedInstance().userId!)
        
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        }()
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if sections.count > 0 {
                let info = sections[section] 
                return info.numberOfObjects
            }
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let venueList = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenueList
        var selected = false
        if let currentSelection = self.selectedList where currentSelection.title == venueList.title {
            selected = true
        }
        
        guard let cell = self.tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) else {
            return setupCell(UITableViewCell(), venueList: venueList, selected: selected)
        }
        
        return setupCell(cell, venueList: venueList, selected: selected)
    }
    
    func setupCell(cell:UITableViewCell, venueList:CDVenueList, selected:Bool) -> UITableViewCell {
        cell.textLabel!.text = venueList.title
        if selected {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.ueraniGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.selectAccessory {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        self.selectedList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDVenueList
        self.venueListSelectionAction?()
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.selectAccessory {
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        }
    }
}
