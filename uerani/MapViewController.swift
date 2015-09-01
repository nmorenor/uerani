//
//  MapViewController.swift
//  uerani
//
//  Created by nacho on 6/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit

import RealmSwift
import CoreData

//allow a protocol to have a weak reference
protocol CategoriesReady : class {
    
    func initializeSearchResults()
}

class MapViewController: UIViewController, CategoriesReady {

    let identifier = "foursquarePin"
    let clusterPin = "foursquareClusterPin"
    let calloutPin = "calloutPin"
    
    let defaultPinImage = "default_32"
    
    @IBOutlet weak var searchBarView: SearchViewWtihProgress!
    @IBOutlet weak var categoryViewSearch: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet var categoryBottomConstraint: NSLayoutConstraint!
    
    var selectedMapAnnotationView:MKAnnotationView?
    var calloutMapAnnotationView:CalloutMapAnnotationView?
    var searchMediator:VenueLocationSearchMediator!
    var isRefreshReady:Bool = false
    
    var searchController = UISearchController()
    var searchShouldBeginEditing = true
    
    private var myContext = 0
    private var userLocationContext = 1
    
    //MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryViewSearch.hidden = true
        let locationRequestManager = LocationRequestManager.sharedInstance()
        self.isRefreshReady = locationRequestManager.authorized
        locationRequestManager.addObserver(self, forKeyPath: "authorized", options: NSKeyValueObservingOptions.New, context: &self.myContext)
        locationRequestManager.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions.New, context: &self.userLocationContext)
        self.searchMediator = VenueLocationSearchMediator(mapView: self.mapView)
        self.mapView.delegate = self
        
        //Initialize maged context on main thread
        var context = self.sharedContext
        self.fetchedResultsController.delegate = self
        
        //search all venue categories in background thread
        VenueCategoriesOperation(delegate: self)
        UserRefreshOperation(delegate: nil)
        
        //do not show lines on empty rows
        self.categoryViewSearch.tableFooterView = UIView(frame: CGRect.zeroRect)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.delegate = self
            
            self.searchBarView.searchBar = controller.searchBar
            
            return controller
        })()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.searchMediator?.mapView = self.mapView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        unsubscribeFromKeyboardNotifications()
        if self.isRefreshReady {
            self.searchMediator.updateUI()
        }
        if self.searchMediator.hasRunningSearch() {
            let searchBeginNotification = NSNotification(name: UERANI_MAP_BEGIN_PROGRESS, object: nil)
            NSNotificationCenter.defaultCenter().postNotification(searchBeginNotification)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        let locationRequestManager = LocationRequestManager.sharedInstance()
        self.searchMediator?.calloutAnnotation = nil
        
        LocationRequestManager.sharedInstance().refreshOperationQueue.cancelAllOperations()
        let searchEndNotification = NSNotification(name: UERANI_MAP_END_PROGRESS, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(searchEndNotification)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.searchMediator.cleanMap()
        self.searchMediator.updateUI()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext || context == &userLocationContext {
            if context == &myContext {
                if let authorized = change[NSKeyValueChangeNewKey] as? Bool {
                    if authorized {
                        self.searchMediator.setAllowLocation()
                    }
                    if !authorized {
                        self.isRefreshReady = true
                    }
                }
            } else {
                if let location = change[NSKeyValueChangeNewKey] as? CLLocation where !self.isRefreshReady {
                    self.searchMediator.displayLocation(location)
                    self.isRefreshReady = true
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK - Core Data
    
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = { [unowned self] in
        let fetchRequest = self.getTopCategoryFetchRequest()
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        }()
    
    func initializeSearchResults() {
        dispatch_async(dispatch_get_main_queue()) {
            let fetchRequest = self.getTopCategoryFetchRequest()
            
            var error:NSError? = nil
            self.fetchedResultsController.performFetch(&error)
            
            if let error = error {
                println("Error performing initial fetch")
            }
            let sectionInfo = self.fetchedResultsController.sections!.first as! NSFetchedResultsSectionInfo
            if sectionInfo.numberOfObjects > 0 {
                self.categoryViewSearch.reloadData()
            }
        }
    }
    
    deinit {
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "authorized", context: &self.myContext)
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "location", context: &self.userLocationContext)
    }
}

extension UISearchController {
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}