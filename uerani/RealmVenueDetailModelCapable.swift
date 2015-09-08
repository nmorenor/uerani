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

public class RealmVenueDetailViewController : UIViewController, VenueDetailModelCapable, VenueDetailsDelegate {
    
    typealias DetailModelType = VenueDetailViewModel<FVenue>
    typealias VenueType = FVenue
    
    var venue:FVenue!
    var venueId:String!
    var venueDetailModel:VenueDetailViewModel<FVenue>!
    @IBOutlet var imageViewTop:VenueImageView!
    var realm:Realm!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ueraniYellowColor()
        self.realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        self.venue = realm.objectForPrimaryKey(FVenue.self, key: venueId)
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.venueDetailModel = self.getVenueDetailModel()
        self.navigationItem.title = venueDetailModel.name
        self.venueDetailModel.setupImageView(self.imageViewTop)
        //self.view.layoutSubviews()
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
        self.venueDetailModel = VenueDetailViewModel(venue: self.venue, imageSize: CGSizeMake(self.imageViewTop.frame.size.width, self.imageViewTop.frame.size.height), delegate: self)
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
            self.venueDetailModel.setupImageView(self.imageViewTop)
            self.imageViewTop.layoutSubviews()
            self.view.layoutIfNeeded()
        }
    }
    
    public func refreshVenueDetailsError(errorString:String) {
        //TODO
        println(errorString)
    }
    
}
