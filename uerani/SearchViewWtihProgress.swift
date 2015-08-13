//
//  SearchViewWtihProgress.swift
//  uerani
//
//  Created by nacho on 8/10/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import QuartzCore

class SearchViewWtihProgress: UIView {

    var searchBar:UISearchBar! {
        didSet {
            self.searchBar.barTintColor = UIColor.blackColor()
            self.searchBar.barStyle = UIBarStyle.Black
            self.searchBar.placeholder = "Categories"
            
            self.addSubview(self.searchBar)
        }
    }
    var progress:SearchViewProgress?
    var onProgress = false
    var mutex:NSObject = NSObject()
    
    override func didMoveToSuperview() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beginProgress", name: "searchBegin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "endProgress", name: "searchEnd", object: nil)
        self.backgroundColor = UIColor.blackColor()
    }
    
    override func layoutSubviews() {
        if progress == nil {
            let refreshRadius:CGFloat = self.frame.size.height/2 * 0.9
            progress = SearchViewProgress(frame: CGRectMake(self.frame.size.width + (refreshRadius * 2), 0, refreshRadius * 2, self.frame.size.height))
            self.addSubview(self.progress!)
            self.layoutIfNeeded()
        }
        if self.onProgress {
            let refreshRadius:CGFloat = self.frame.size.height/2 * 0.9
            self.searchBar.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width - ((refreshRadius * 2) + 2), self.frame.size.height)
        } else {
            self.searchBar.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height)
        }
    }
    
    func beginProgress() {
        var shouldReturn = false
        objc_sync_enter(self.mutex)
        if self.onProgress {
            shouldReturn = true
        }
        self.onProgress = true
        objc_sync_exit(self.mutex)
        if shouldReturn {
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.progress?.beginProgress()
            let refreshRadius:CGFloat = self.frame.size.height/2 * 0.9
            UIView.animateWithDuration(0.4, animations: { [unowned self] in
                    self.searchBar.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width - ((refreshRadius * 2) + 2) , self.frame.size.height)
                    self.progress!.frame = CGRectMake(self.searchBar.frame.width + 4, 0, refreshRadius * 2, self.frame.size.height)
                
                }, completion: nil)
        }
    }
    
    func endProgress() {
        var shouldReturn = false
        objc_sync_enter(self.mutex)
        if !self.onProgress {
            shouldReturn = true
        }
        self.onProgress = false
        objc_sync_exit(self.mutex)
        if shouldReturn {
            return
        }
        dispatch_async(dispatch_get_main_queue()) {
            let refreshRadius:CGFloat = self.frame.size.height/2 * 0.9
            UIView.animateWithDuration(0.3, animations: { [unowned self] in
                    self.searchBar.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height)
                    self.progress?.frame = CGRectMake(self.frame.size.width + (refreshRadius * 2), 0, refreshRadius * 2, self.frame.size.height)
                }, completion: { [unowned self] _ in
                    self.progress?.endProgress()
                })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
