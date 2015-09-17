//
//  RealmVenueDetailViewController.swift
//  uerani
//
//  Created by nacho on 9/7/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol VenueDetailModelCapable : class {
    
    typealias DetailModelType
    typealias VenueType
    
    func getVenueDetailModel() -> DetailModelType
    func getVenue() -> VenueType
}

public class RealmVenueDetailViewController : UIViewController, VenueDetailModelCapable, VenueDetailsDelegate, VenueMapImageDelegate {
    
    typealias DetailModelType = VenueDetailViewModel<FVenue>
    typealias VenueType = FVenue
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView! {
        didSet {
            self.contentView.backgroundColor = UIColor.ueraniYellowColor()
        }
    }
    @IBOutlet weak var venueRating: VenueRatingView!
    
    @IBOutlet weak var venueDetailsView: VenueDetailsView!
    @IBOutlet weak var venueDetailsHeightConstraint: NSLayoutConstraint!
    
    var venue:FVenue!
    var venueId:String!
    var venueDetailModel:VenueDetailViewModel<FVenue>!
    var listDialogController:AddVenueToListController?
    @IBOutlet var imageViewTop:VenueImageView! {
        didSet {
            self.imageViewTop.backgroundColor = UIColor.ueraniYellowColor()
        }
    }
    var realm:Realm!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ueraniYellowColor()
        self.realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        self.venue = realm.objectForPrimaryKey(FVenue.self, key: venueId)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "handleAddList:")
        self.venueDetailModel = self.getVenueDetailModel()
        self.navigationItem.title = venueDetailModel.name
        self.venueDetailModel.setupImageView(self.imageViewTop, imageMapDelegate:self, venue:venue)
        
        self.venueDetailModel.setupRatingView(self.venueRating)
        self.venueDetailModel.setupDetailsView(self.venueDetailsView)
        self.venueDetailsHeightConstraint.constant = self.venueDetailsView.frame.size.height * 1.35
        
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func handleAddList(button:UIBarButtonItem) {
        self.listDialogController = AddVenueToListController()
        self.listDialogController?.addCloseAction(self.closeDialog)
        self.listDialogController?.show(self)
    }
    
    func closeDialog() {
        if let alertView = self.listDialogController {
            
        }
        self.listDialogController = nil
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    public func getVenueDetailModel() -> VenueDetailViewModel<FVenue> {
        if let model = self.venueDetailModel {
            return model
        }
        self.venueDetailModel = VenueDetailViewModel(venue: self.venue, imageSize: CGSizeMake(self.imageViewTop.frame.size.width, self.imageViewTop.frame.size.height), updateCoreData:false, delegate: self)
        //return self.venueDetailModel!
        return self.venueDetailModel!
    }
    
    public func getVenue() -> FVenue {
        return self.venue
    }
    
    public func refreshVenueDetails(venueId:String) {
        dispatch_async(dispatch_get_main_queue()) {
            let realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
            realm.refresh()
            self.venue = realm.objectForPrimaryKey(FVenue.self, key: venueId)
            self.venueDetailModel.loadData(self.venue)
            self.navigationItem.title = self.venueDetailModel.name
            self.venueDetailModel.setupImageView(self.imageViewTop, imageMapDelegate:self, venue: self.venue)
            self.venueDetailModel.setupRatingView(self.venueRating)
            self.venueDetailModel.setupDetailsView(self.venueDetailsView)
            self.venueRating.layoutSubviews()
            self.imageViewTop.layoutSubviews()
            
            self.venueDetailsHeightConstraint.constant = self.venueDetailsView.frame.size.height * 1.35
            
            self.view.setNeedsLayout()
            self.view.setNeedsUpdateConstraints()
            self.view.layoutIfNeeded()
        }
    }
    
    public func refreshMapImage() {
        dispatch_async(dispatch_get_main_queue()) {
            self.venueDetailModel.setupImageView(self.imageViewTop, imageMapDelegate:self, venue: self.venue)
            self.imageViewTop.layoutSubviews()
            self.view.layoutIfNeeded()
        }
    }
    
    public func refreshVenueDetailsError(errorString:String) {
        //TODO
        println(errorString)
    }
    
}
