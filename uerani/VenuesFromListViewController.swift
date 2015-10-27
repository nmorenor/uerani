//
//  VenuesFromListViewController.swift
//  uerani
//
//  Created by nacho on 9/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class VenuesFromListViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    var list:CDVenueList!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        var error:NSError? = nil
        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if let _ = error {
            if DEBUG {
                print("Error performing initial fetch")
            }
            return
        }
        let sectionInfo = self.fetchedResultsController.sections!.first!
        if sectionInfo.numberOfObjects > 0 {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.sharedContext.objectWithID(list.objectID)
        self.navigationItem.title = list.title
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK - Core Data
    
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "CDVenue")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "venueLists.user.id contains[cd] %@ AND venueLists.title contains[cd] %@", FoursquareClient.sharedInstance().userId!, self.list.title)
        
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        }()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if sections.count > 0 {
                let info = sections[section] 
                return info.numberOfObjects
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
        
        var venueCell:UITableViewCell!
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("venueCell") {
            venueCell = setupCell(cell, venue: venue)
        } else {
            venueCell = setupCell(UITableViewCell(), venue: venue)
        }
        
        
        if let bestPhoto = venue.bestPhoto {
            let rect = tableView.rectForRowAtIndexPath(indexPath)
            let url = NSURL(string: "\(bestPhoto.iprefix)\(rect.size.height.getIntValue())x\(rect.size.height.getIntValue())\(bestPhoto.isuffix)")!
            if let identifier = getImageIdentifier(url) {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(identifier) {
                    let imageView = UIImageView(image: image)
                    venueCell.accessoryView = imageView
                } else {
                    FoursquareClient.sharedInstance().httpClient!.taskForImage(url, completionHandler: { imageData, error in
                        if let _ = error {
                            if DEBUG {
                                Swift.print("Can not download venue image for list")
                            }
                        } else if let data = imageData {
                            dispatch_async(dispatch_get_main_queue()) {
                                let image = UIImage(data: data)
                                ImageCache.sharedInstance().storeImage(image, withIdentifier: identifier)
                                let imageView = UIImageView(image: image)
                                venueCell.accessoryView = imageView
                            }
                        }
                    })
                }
            }
        
        }
        
        return venueCell
    }
    
    func setupCell(cell:UITableViewCell, venue:CDVenue) -> UITableViewCell {
        cell.textLabel!.text = venue.name
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
            let venueLists = venue.mutableSetValueForKey("venueLists")
            let venues = self.list.mutableSetValueForKey("venues")
            
            venueLists.removeObject(self.list)
            venues.removeObject(venue)
            
            self.sharedContext.refreshObject(self.list, mergeChanges: true)
            self.sharedContext.refreshObject(venue, mergeChanges: true)
            
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.ueraniGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
        let detailsController = self.storyboard?.instantiateViewControllerWithIdentifier("RealmDetailsViewController") as! RealmVenueDetailViewController
        detailsController.venueId = venue.id
        detailsController.updateCoreData = true
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
            case NSFetchedResultsChangeType.Insert :
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                    break
            case NSFetchedResultsChangeType.Delete :
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                break
            default:
                break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
