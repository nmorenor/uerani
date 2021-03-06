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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout", name: UERANI_LOGOUT, object: nil)
        
        self.categoryViewSearch.hidden = true
        let locationRequestManager = LocationRequestManager.sharedInstance()
        self.isRefreshReady = locationRequestManager.authorized
        self.searchMediator = VenueLocationSearchMediator(mapView: self.mapView)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        if let location = locationRequestManager.location {
            self.searchMediator.displayLocation(location)
        }
        
        locationRequestManager.addObserver(self, forKeyPath: "authorized", options: NSKeyValueObservingOptions.New, context: &self.myContext)
        locationRequestManager.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions.New, context: &self.userLocationContext)
        self.mapView.delegate = self
        
        //Initialize maged context on main thread
        _ = self.sharedContext
        self.fetchedResultsController.delegate = self
        
        //search all venue categories in background thread
        _ = VenueCategoriesOperation(delegate: self)
        _ = UserRefreshOperation(delegate: nil)
        
        //do not show lines on empty rows
        self.categoryViewSearch.tableFooterView = UIView(frame: CGRect.zero)
        
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
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
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
        _ = LocationRequestManager.sharedInstance()
        self.searchMediator?.calloutAnnotation = nil
        
        LocationRequestManager.sharedInstance().refreshOperationQueue.cancelAllOperations()
        let searchEndNotification = NSNotification(name: UERANI_MAP_END_PROGRESS, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(searchEndNotification)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.searchMediator.cleanMap()
        self.searchMediator.updateUI()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext || context == &userLocationContext {
            if context == &myContext {
                if let authorized = change![NSKeyValueChangeNewKey] as? Bool {
                    if authorized {
                        self.searchMediator.setAllowLocation()
                    }
                    if !authorized {
                        self.isRefreshReady = true
                    }
                }
            } else {
                if let location = change![NSKeyValueChangeNewKey] as? CLLocation where !self.isRefreshReady {
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
    
    func logout() {
        self.searchMediator.cleanMap()
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
            
            var error:NSError? = nil
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
            
            if let _ = error {
                print("Error performing initial fetch")
            }
            let sectionInfo = self.fetchedResultsController.sections!.first!
            if sectionInfo.numberOfObjects > 0 {
                self.categoryViewSearch.reloadData()
            }
        }
    }
    
    deinit {
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "authorized", context: &self.myContext)
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "location", context: &self.userLocationContext)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension UISearchController {
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}