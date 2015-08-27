//
//  MapViewSearchDelegate.swift
//  uerani
//
//  Created by nacho on 8/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension MapViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil);
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil);
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (self.searchController.searchBar.isFirstResponder()) {
            /** Some of the custom keyboards (like swype) can incorrectly report keyboardWillShow method multiple times. We could get bad behaviour if we use self.view.frame.origin.y -= getKeyboardHeight(notification);
            
            http://stackoverflow.com/questions/25874975/cant-get-correct-value-of-keyboard-height-in-ios8
            */
            self.categoryBottomConstraint.constant = (getKeyboardHeight(notification) - (self.tabBarController != nil ? self.tabBarController!.tabBar.frame.height : 0))
            UIView.animateWithDuration(1.0, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.searchController.searchBar.isFirstResponder()) {
            self.categoryBottomConstraint.constant = 0;
            UIView.animateWithDuration(1.0, animations: { [unowned self] in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo;
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue;
        return keyboardSize.CGRectValue().height
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.mapView.hidden = true
        self.categoryViewSearch.hidden = false
        
        self.categoryViewSearch.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.isFirstResponder() {
            self.searchShouldBeginEditing = false
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        let result = self.searchShouldBeginEditing
        self.searchShouldBeginEditing = true
        return result
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchPredicate = searchController.searchBar.text.isEmpty ? NSPredicate(format: "topCategory == %@", NSNumber(bool: true)) : NSPredicate(format: "name contains[c] %@", searchController.searchBar.text)
        self.fetchedResultsController.fetchRequest.predicate = searchPredicate
        
        var error:NSError? = nil
        self.fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing doing a search fetch")
        }
        let sectionInfo = self.fetchedResultsController.sections!.first as! NSFetchedResultsSectionInfo
        
        self.categoryViewSearch.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.mapView.hidden = false
        self.categoryViewSearch.hidden = true
        
        if self.searchMediator.categoryFilter != nil {
            self.searchMediator.doSearchWithCategory(nil)
        }
    }
}
