//
//  UberConvenience.swift
//  uerani
//
//  Created by nacho on 9/21/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

extension UberClient {

    
    func getUberPricesForLocation(startPoint:CLLocationCoordinate2D, endPoint:CLLocationCoordinate2D, completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        var parameters:[String:AnyObject] = [
            UberClient.ParameterKeys.START_LATITUDE : "\(startPoint.latitude)",
            UberClient.ParameterKeys.START_LONGITUDE : "\(startPoint.longitude)",
            UberClient.ParameterKeys.END_LATITUDE: "\(endPoint.latitude)",
            UberClient.ParameterKeys.END_LONGITUDE: "\(endPoint.longitude)"
        ]
        
        self.httpClient?.taskForGETMethod(UberClient.Methods.ESTIMATE_PRICE, parameters: parameters) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, result: nil, errorString: "Error while searching uber prices")
            } else {
                if DEBUG {
                    println(JSONResult)
                }
                if let prices = JSONResult.valueForKey(UberClient.ResponseKeys.PRICES) as? [[String:AnyObject]] {
                    completionHandler(success: true, result: prices, errorString: nil)
                } else {
                    completionHandler(success: false, result: nil, errorString: "Error while searching uber prices")
                }
            }
        }
    }
}
