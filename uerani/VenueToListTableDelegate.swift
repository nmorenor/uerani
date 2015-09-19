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

public class VenueToListTableDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var tableView:UITableView
    weak var selectedList:CDVenueList?
    
    init(tableView:UITableView) {
        self.tableView = tableView
        super.init()
        
        var error:NSError? = nil
        self.fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch")
        }
        let sectionInfo = self.fetchedResultsController.sections!.first as! NSFetchedResultsSectionInfo
        if sectionInfo.numberOfObjects > 0 {
            self.tableView.reloadData()
        }
    }
    
    // MARK - Core Data
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "CDVenueList")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "user.id == %@", FoursquareClient.sharedInstance().userId!)
        
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        }()
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if sections.count > 0 {
                let info = sections[section] as! NSFetchedResultsSectionInfo
                return info.numberOfObjects
            }
        }
        return 0
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let venueList = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenueList
        let CellIdentifier = "venueListCell"
        var selected = false
        if let currentSelection = self.selectedList where currentSelection.title == venueList.title {
            selected = true
        }
        
        if let cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? UITableViewCell {
            cell.textLabel!.text = venueList.title
            if selected {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            return cell
        } else {
            var cell = UITableViewCell()
            cell.textLabel!.text = venueList.title
            if selected {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            return cell
        }
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        self.selectedList = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDVenueList
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
}
