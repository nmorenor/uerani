//
//  MapViewCategoriesTableDelegate.swift
//  uerani
//
//  Created by nacho on 8/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension MapViewController: UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            if sections.count > 0 {
                let info = sections[section] as! NSFetchedResultsSectionInfo
                return info.numberOfObjects
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDCategory
        let CellIdentifier = "categorySearchCell"
        
        let cell = self.categoryViewSearch.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        configureCell(cell, category: category)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let category = self.fetchedResultsController.objectAtIndexPath(indexPath) as? CDCategory {
            let categoryId = category.id
            self.mapView.hidden = false
            self.categoryViewSearch.hidden = true
            self.searchController.active = false
            self.searchController.searchBar.text = category.name
            self.searchMediator.doSearchWithCategory(category.getCategoriesIds())
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, category: CDCategory) {
        var categoryImage = UIImage(named: defaultPinImage)
        
        cell.textLabel!.text = category.name
        cell.imageView!.image = nil
        
        // Set the category image
        if let url = NSURL(string: "\(category.icon.prefix)\(FIcon.FIconSize.S32.description)\(category.icon.suffix)"), let name = url.lastPathComponent, let pathComponents = url.pathComponents {
            let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
            let imageName = "\(prefix_image_name)_\(name)"
            if let image = ImageCache.sharedInstance().imageWithIdentifier(imageName) {
                categoryImage = image
            }
        }
        
        //pngs are white use black color
        cell.imageView!.image = categoryImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.imageView!.tintColor = UIColor.blackColor()
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func getTopCategoryFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "CDCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "topCategory == %@", NSNumber(bool: true))
        return fetchRequest
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.categoryViewSearch.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert :
            self.categoryViewSearch.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            break
        case .Delete :
            self.categoryViewSearch.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.categoryViewSearch.endUpdates()
    }
}