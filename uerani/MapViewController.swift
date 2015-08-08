//
//  MapViewController.swift
//  uerani
//
//  Created by nacho on 6/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit
import FBAnnotationClustering
import RealmSwift
import CoreData

protocol CategoriesReady : class {
    
    func initializeSearchResults()
}

class MapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CategoriesReady, UISearchBarDelegate, UISearchResultsUpdating {

    let identifier = "foursquarePin"
    let clusterPin = "foursquareClusterPin"
    let calloutPin = "calloutPin"
    
    let defaultPinImage = "default_32.png"
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var categoryViewSearch: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedMapAnnotationView:MKAnnotationView?
    var calloutMapAnnotationView:CalloutMapAnnotationView?
    var requestProcessor:MapLocationRequestProcessor!
    var isRefreshReady:Bool = false
    
    var resultSearchController = UISearchController()
    
    private var myContext = 0
    private var userLocationContext = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categoryViewSearch.hidden = true
        let locationRequestManager = LocationRequestManager.sharedInstance()
        self.isRefreshReady = locationRequestManager.authorized
        locationRequestManager.addObserver(self, forKeyPath: "authorized", options: NSKeyValueObservingOptions.New, context: &self.myContext)
        locationRequestManager.addObserver(self, forKeyPath: "location", options: NSKeyValueObservingOptions.New, context: &self.userLocationContext)
        self.requestProcessor = MapLocationRequestProcessor(mapView: self.mapView)
        self.mapView.delegate = self
        
        //Initialize maged context on main thread
        var context = self.sharedContext
        self.fetchedResultsController.delegate = self
        
        //search all venue categories in background thread
        VenueCategoriesOperation(delegate: self)
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            controller.searchBar.delegate = self
            
            self.searchBarView.addSubview(controller.searchBar)
            
            return controller
        })()
        
    }
    
    func initializeSearchResults() {
        dispatch_async(dispatch_get_main_queue()) {
            let fetchRequest = NSFetchRequest(entityName: "CDCategory")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "topCategory == %@", NSNumber(bool: true))
            
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
    
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    lazy var fetchedResultsController:NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "CDCategory")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "topCategory == %@", NSNumber(bool: true))
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return controller
        }()
    
    override func viewWillAppear(animated: Bool) {
        self.requestProcessor?.mapView = self.mapView
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        let locationRequestManager = LocationRequestManager.sharedInstance()
        self.requestProcessor?.calloutAnnotation = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &myContext || context == &userLocationContext {
            if context == &myContext {
                if let authorized = change[NSKeyValueChangeNewKey] as? Bool {
                    if authorized {
                        self.requestProcessor.setAllowLocation()
                    }
                    if !authorized {
                        self.isRefreshReady = true
                    }
                }
            } else {
                if let location = change[NSKeyValueChangeNewKey] as? CLLocation where !self.isRefreshReady {
                    self.requestProcessor.displayLocation(location)
                    self.isRefreshReady = true
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func handleSearch(button:UIBarButtonItem) {
        self.performSegueWithIdentifier("venueFilter", sender: self)
    }
    
    // MARK: - Table View
    
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
        let movie = self.fetchedResultsController.objectAtIndexPath(indexPath) as! CDCategory
        let CellIdentifier = "categorySearchCell"
        
        let cell = self.categoryViewSearch.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        configureCell(cell, category: movie)
        
        return cell
    }
    
    // MARK: - Fetched Results Controller Delegate
    
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
    
    // MARK: - Configure Cell
    
    func configureCell(cell: UITableViewCell, category: CDCategory) {
        var categoryImage = UIImage(named: "default_32")
        
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
        
        cell.imageView!.image = categoryImage
    }
    
    //MARK: - Search Bar
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.mapView.hidden = true
        self.categoryViewSearch.hidden = false
        
        self.categoryViewSearch.reloadData()
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
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    deinit {
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "authorized", context: &self.myContext)
        LocationRequestManager.sharedInstance().removeObserver(self, forKeyPath: "location", context: &self.userLocationContext)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let calloutAnnotation = self.requestProcessor.calloutAnnotation {
            mapView.removeAnnotation(calloutAnnotation)
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let clusterAnnotation = view.annotation as? FBAnnotationCluster {
            return
        }
        
        let requestProcessor = self.requestProcessor
        
        requestProcessor.calloutAnnotation = CalloutAnnotation(coordinate: view.annotation.coordinate)
        self.selectedMapAnnotationView = view
        mapView.addAnnotation(requestProcessor.calloutAnnotation!)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let userAnnotation = annotation as? MKUserLocation {
            return nil
        }
        
        var view:MKPinAnnotationView?
        if let cluserAnnotation = annotation as? FBAnnotationCluster {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(clusterPin) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: clusterPin)
            }
            self.drawCircleImage(cluserAnnotation, view: view!)
            
        } else if let foursquareAnnotation = annotation as? FoursquareLocationMapAnnotation {
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? BasicMapAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = BasicMapAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if let categoryImageName = foursquareAnnotation.categoryImageName {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                    self.drawCategoryImage(view!, image: image)
                } else if let prefix = foursquareAnnotation.categoryPrefix, let suffix = foursquareAnnotation.categorySuffix {
                    FoursquareCategoryIconWorker(prefix: prefix, suffix: suffix)
                    if let image = UIImage(named: defaultPinImage) {
                        self.drawCategoryImage(view!, image: image)
                    }
                } else {
                    if let image = UIImage(named: defaultPinImage) {
                        self.drawCategoryImage(view!, image: image)
                    }
                }
            }
            view!.canShowCallout = false
        }
        if let view = view {
            return view
        }
        
        var customView:AccesorizedCalloutAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(calloutPin) as? AccesorizedCalloutAnnotationView {
            customView = dequeuedView
        } else {
            customView = AccesorizedCalloutAnnotationView(annotation: annotation, reuseIdentifier: calloutPin)
            
        }
        customView.mapView = mapView
        customView.parentAnnotationView = self.selectedMapAnnotationView!
        customView.annotation = annotation
        customView.contentHeight = 80.0
        if let annotation = self.selectedMapAnnotationView?.annotation as? FoursquareLocationMapAnnotation {
            customView.contentView().subviews.map({$0.removeFromSuperview()})
            let contentFrame = customView.getContentFrame()
            if let let categoryImageName = annotation.categoryImageName64 {
                if let image = ImageCache.sharedInstance().imageWithIdentifier(categoryImageName) {
                    var aView = FoursquareAnnotationVenueInformationView()
                    aView.image = image
                    aView.name = annotation.title
                    aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                    aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                    customView.contentView().addSubview(aView)
                }
            } else {
                if let image = ImageCache.sharedInstance().imageWithIdentifier("default_64") {
                    var aView = FoursquareAnnotationVenueInformationView()
                    aView.image = image
                    aView.name = annotation.title
                    aView.address = "City: \(annotation.city), \(annotation.state)\nAddress: \(annotation.subtitle)"
                    aView.frame = CGRectMake(2, 3, contentFrame.size.width - 8, contentFrame.size.height - 6)
                    customView.contentView().subviews.map({$0.removeFromSuperview()})
                    customView.contentView().addSubview(aView)
                }
            }
        }
        customView.superview?.bringSubviewToFront(customView)
        
        return customView
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if self.isRefreshReady {
            RefreshMapAnnotationOperation(mapView: mapView, requestProcessor: self.requestProcessor)
        }
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        if fullyRendered && self.isRefreshReady {
            self.requestProcessor.triggerLocationSearch(mapView.region)
        }
    }
    
    func drawCategoryImage(view:MKPinAnnotationView, image:UIImage) {
        let containerLayer = CALayer()
        var yellowColor = UIColor(red: 255.0/255.0, green: 188.0/255.0, blue: 8/255.0, alpha: 1.0)
        containerLayer.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height + 30)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, image.size.width + 10, image.size.height + 10)).CGPath
        circleLayer.fillColor = yellowColor.CGColor
        circleLayer.backgroundColor = UIColor.clearColor().CGColor
        
        let triangleLayer = CAShapeLayer()
        triangleLayer.frame = CGRectMake(0, image.size.height - ((image.size.height / 4) + 2), image.size.width + 10, 30)
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPoint(x: 0, y: 0))
        bezierPath.addLineToPoint(CGPoint(x: (image.size.width + 10) / 2, y: 30))
        bezierPath.addLineToPoint(CGPoint(x: image.size.width + 10, y: 0))
        
        bezierPath.closePath()
        triangleLayer.path = bezierPath.CGPath
        triangleLayer.fillColor = yellowColor.CGColor
        triangleLayer.backgroundColor = UIColor.clearColor().CGColor
        
        let imageLayer = CALayer()
        imageLayer.frame = CGRectMake(5, 5, image.size.width, image.size.height)
        imageLayer.contents = image.CGImage
        
        containerLayer.addSublayer(circleLayer)
        containerLayer.addSublayer(triangleLayer)
        containerLayer.addSublayer(imageLayer)
        
        UIGraphicsBeginImageContextWithOptions(containerLayer.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        containerLayer.renderInContext(context)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = resultImage
    }
    
    func drawCircleImage(annotation:FBAnnotationCluster, view:MKPinAnnotationView) {
        let number = annotation.annotations.count
        
        let fontSize:CGFloat = number > 9 ? 30 : 20
        var font = UIFont(name: "Helvetica", size: fontSize)!
        var yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
        var attributedString = NSAttributedString(string: String(annotation.annotations.count), attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName: yellowColor])
        let asize:CGSize = attributedString.size()
        let size = max((asize.width + 10), 30)
        
        let label = CATextLayer()
        label.frame = CGRectMake(5, ((((size - 5) - fontSize) / 2) + 5), size, size)
        label.alignmentMode = kCAAlignmentCenter
        label.allowsEdgeAntialiasing = true
        label.string = attributedString
        label.backgroundColor = UIColor.clearColor().CGColor
        label.foregroundColor = yellowColor.CGColor

        let backCircle = CAShapeLayer()
        backCircle.path = UIBezierPath(ovalInRect: CGRectMake(0, 0, size + 10, size + 10)).CGPath
        backCircle.fillColor = yellowColor.CGColor
        backCircle.backgroundColor = UIColor.clearColor().CGColor
        
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRectMake(5, 5, size, size)).CGPath
        circle.fillColor = UIColor.blackColor().CGColor
        circle.backgroundColor = UIColor.clearColor().CGColor
        backCircle.addSublayer(circle)
        circle.addSublayer(label)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size + 10, height: size + 10), false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        backCircle.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        view.image = image
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let overlay = overlay as? MKPolygon {
            var renderer = MKPolygonRenderer(polygon: overlay)
            renderer.fillColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            renderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            renderer.lineWidth = 1
            return renderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("Hello world")
    }
}

