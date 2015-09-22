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

class VenuesFromListViewController : UITableViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var list:CDVenueList!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        var error:NSError? = nil
        self.fetchedResultsController.delegate = self
        self.fetchedResultsController.performFetch(&error)
        self.tableView.tableFooterView = UIView(frame: CGRect.zeroRect)
        
        if let error = error {
            println("Error performing initial fetch")
        }
        let sectionInfo = self.fetchedResultsController.sections!.first as! NSFetchedResultsSectionInfo
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
                let info = sections[section] as! NSFetchedResultsSectionInfo
                return info.numberOfObjects
            }
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
        
        var venueCell:UITableViewCell!
        if let cell = self.tableView.dequeueReusableCellWithIdentifier("venueCell") as? UITableViewCell {
            cell.textLabel!.text = venue.name
            venueCell = cell
        } else {
            var cell = UITableViewCell()
            cell.textLabel!.text = venue.name
            venueCell = cell
        }
        
        if let bestPhoto = venue.bestPhoto {
            var rect = tableView.rectForRowAtIndexPath(indexPath)
            let url = NSURL(string: "\(bestPhoto.iprefix)\(rect.size.height.getIntValue())x\(rect.size.height.getIntValue())\(bestPhoto.isuffix)")!
            if let identifier = getImageIdentifier(url) {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(identifier) {
                    var imageView = UIImageView(image: image)
                    venueCell.accessoryView = imageView
                } else {
                    FoursquareClient.sharedInstance().httpClient!.taskForImage(url, completionHandler: { imageData, error in
                        if let error = error {
                            println("Can not download venue image for list")
                        } else if let data = imageData {
                            dispatch_async(dispatch_get_main_queue()) {
                                var image = UIImage(data: data)
                                ImageCache.sharedInstance().storeImage(image, withIdentifier: identifier)
                                var imageView = UIImageView(image: image)
                                venueCell.accessoryView = imageView
                            }
                        }
                    })
                }
            }
        
        }
        
        return venueCell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            let venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
            var venueLists = venue.mutableSetValueForKey("venueLists")
            var venues = self.list.mutableSetValueForKey("venues")
            
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
        var venue = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDVenue
        var detailsController = self.storyboard?.instantiateViewControllerWithIdentifier("RealmDetailsViewController") as! RealmVenueDetailViewController
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
