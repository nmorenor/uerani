//
//  UberPriceViewModel.swift
//  uerani
//
//  Created by nacho on 9/21/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

class UberPriceViewModel {
    
    var uberDetailDelegate:VenueDetailsDelegate
    var venueId:String
    var venueLocation:CLLocationCoordinate2D
    
    var estimate:String?
    var currencyCode:String?
    
    init(venueId:String, venueLocation:CLLocationCoordinate2D, delegate:VenueDetailsDelegate) {
        self.venueId = venueId
        self.venueLocation = venueLocation
        self.uberDetailDelegate = delegate
        
        if let location = LocationRequestManager.sharedInstance().location {
            UberClient.sharedInstance().getUberPricesForLocation(location.coordinate, endPoint: venueLocation, completionHandler: self.uberPriceHandler)
        }
    }
    
    func uberPriceHandler(success:Bool, result:[[String:AnyObject]]?, errorString:String?) {
        if let error = errorString {
            self.uberDetailDelegate.refreshVenueDetailsError("error on price request to uber")
        } else {
            var price = result!.first!
            self.estimate = price[UberClient.ResponseKeys.ESTIMATE] as? String
            if let currencyCode = price[UberClient.ResponseKeys.CURRENCY_CODE] as? String {
                self.currencyCode = currencyCode
            }
            self.uberDetailDelegate.refreshVenueDetails(self.venueId)
        }
    }
}
