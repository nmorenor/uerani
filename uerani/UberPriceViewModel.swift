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
    
    var value:String?
    
    init(venueId:String, venueLocation:CLLocationCoordinate2D, delegate:VenueDetailsDelegate) {
        self.venueId = venueId
        self.venueLocation = venueLocation
        self.uberDetailDelegate = delegate
    }
    
    func requestFare() {
        if let location = LocationRequestManager.sharedInstance().location {
            UberClient.sharedInstance().getUberPricesForLocation(location.coordinate, endPoint: venueLocation, completionHandler: self.uberPriceHandler)
        }
    }
    
    func uberPriceHandler(success:Bool, result:[[String:AnyObject]]?, errorString:String?) {
        if let _ = errorString {
            self.uberDetailDelegate.refreshVenueDetailsError("error on price request to uber")
        } else {
            var resultValue = ""
            for i in 0..<result!.count {
                let price = result![i]
                let estimate = price[UberClient.ResponseKeys.ESTIMATE] as? String
                let currencyCode = price[UberClient.ResponseKeys.CURRENCY_CODE] as? String
                let displayName = price[UberClient.ResponseKeys.DISPLAY_NAME] as? String
                if let estimate = estimate, currencyCode = currencyCode, displayName = displayName {
                    resultValue += "\(displayName): \(estimate) \(currencyCode)"
                }
                if i < (result!.count - 1) {
                    resultValue += "\n"
                }
            }
            if !resultValue.isEmpty {
                self.value = resultValue
            }
            self.uberDetailDelegate.refreshVenueDetails(self.venueId)
        }
    }
}
