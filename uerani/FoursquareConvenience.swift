//
//  FoursquareConvenience.swift
//  uerani
//
//  Created by nacho on 6/10/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import MapKit

extension FoursquareClient {
    
    public func searchVenuesForLocation(location: CLLocationCoordinate2D, completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        var parameters:[String:AnyObject] = [
            FoursquareClient.ParameterKeys.LATITUDE_LONGITUDE : "\(location.latitude),\(location.longitude)",
            FoursquareClient.ParameterKeys.LIMIT : FoursquareClient.Constants.FOURSQUARE_VENUE_LIMIT
        ]
        parameters = self.addAuthParameters(parameters)
        
        self.doGETAPI(FoursquareClient.Methods.VENUE_SEARCH, key: FoursquareClient.RespnoseKeys.VENUES, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func searchVenuesForLocationInBox(sw: CLLocationCoordinate2D, ne:CLLocationCoordinate2D, completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        var parameters:[String:AnyObject] = [
            FoursquareClient.ParameterKeys.INTENT : FoursquareClient.Constants.FOURSQUARE_BROWSE_INTENT,
            FoursquareClient.ParameterKeys.SW : "\(sw.latitude),\(sw.longitude)",
            FoursquareClient.ParameterKeys.NE : "\(ne.latitude),\(ne.longitude)",
            FoursquareClient.ParameterKeys.LIMIT : FoursquareClient.Constants.FOURSQUARE_VENUE_LIMIT
        ]
        parameters = self.addAuthParameters(parameters)
        
        self.doGETAPI(FoursquareClient.Methods.VENUE_SEARCH, key: FoursquareClient.RespnoseKeys.VENUES, parameters: parameters, completionHandler: completionHandler)
    }
    
    public func searchCategories(completionHandler:(success:Bool, result:[[String:AnyObject]]?, errorString:String?) -> Void) {
        let parameters = self.addAuthParameters([String:AnyObject]())
        
        self.doGETAPI(FoursquareClient.Methods.VENUE_CATEGORY, key: FoursquareClient.RespnoseKeys.CATEGORIES, parameters: parameters) { (scuccess:Bool, result:[[String:AnyObject]]?, errorString:String?) in
            if let error = errorString {
                completionHandler(success: false, result: nil, errorString: error)
            } else {
                var completionResult = result!
                
                var topCategories = [[String:AnyObject]]()
                for category in completionResult {
                    var next = [String:AnyObject]()
                    for nextKey in category.keys {
                        next[nextKey] = category[nextKey]
                    }
                    next["topCategory"] = true
                    topCategories.append(next)
                }
                
                completionHandler(success: true, result: topCategories, errorString: nil)
            }
        }
    }
    
    public func getVenueDetail(venueID:String, completionHandler:(success:Bool, result:[String:AnyObject]?, errorString:String?) -> Void) {
        let parameters = self.addAuthParameters([String:AnyObject]())
        
        let method = HTTPClient.substituteKeyInMethod(FoursquareClient.Methods.VENUE_DETAIL, key: "id", value: venueID)!

        self.doGETAPI(method, key: FoursquareClient.RespnoseKeys.VENUE, parameters: parameters) { (scuccess:Bool, result:[String:AnyObject]?, errorString:String?) in
                if let error = errorString {
                    completionHandler(success: false, result: nil, errorString: error)
                } else {
                    var completionResult = result!
                    var completionPhotos:[[String:AnyObject]]? = nil
                    if let photos = completionResult["photos"] as? [String:AnyObject] where photos["groups"] != nil {
                        let groups = photos["groups"] as! [[String:AnyObject]]
                        for nextGroup in groups {
                            if let type = nextGroup["type"] as? String where type == FoursquareClient.RespnoseKeys.VENUE {
                                if let items = nextGroup["items"] as? [[String:AnyObject]] {
                                    completionPhotos = items
                                    break
                                }
                            }
                        }
                    }
                    
                    var completionTags:[[String:String]]? = nil
                    if let tags = completionResult["tags"] as? [String] {
                        completionTags = [[String:String]]()
                        for nextTag in tags {
                            completionTags!.append(["tagvalue" : nextTag])
                        }
                    }
                    
                    completionResult["tags"] = completionTags ?? nil
                    completionResult["photos"] = completionPhotos ?? nil
                    completionHandler(success: true, result: completionResult, errorString: nil)
                }
            }
    }
    
    private func doGETAPI<T:CollectionType>(method:String, key:String, parameters:[String:AnyObject], completionHandler:(success:Bool, result:T?, errorString:String?) -> Void) {
        self.httpClient?.taskForGETMethod(method, parameters: parameters) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, result: nil, errorString: "Error while searching \(key)")
            } else {
                if DEBUG {
                    println(JSONResult)
                }
                if let meta = JSONResult.valueForKey(FoursquareClient.RespnoseKeys.Meta) as? [String:AnyObject] {
                    if let code = meta[FoursquareClient.RespnoseKeys.Code] as? NSNumber {
                        let responseCode = Int(code)
                        if (responseCode == 200) {
                            if let response = JSONResult.valueForKey(FoursquareClient.RespnoseKeys.Response) as? [String:AnyObject] {
                                if let result = response[key] as? T {
                                    completionHandler(success: true, result: result, errorString: nil)
                                } else {
                                    completionHandler(success: false, result: nil, errorString: "No \(key) found")
                                }
                            } else {
                                completionHandler(success: false, result: nil, errorString: "No \(key) found")
                            }
                        } else {
                            var apiError = "code=\(responseCode)"
                            if let errorType = meta[FoursquareClient.RespnoseKeys.ErrorType] as? String {
                                apiError = "\(apiError) errorType=\(errorType)"
                            }
                            if let errorDetail = meta[FoursquareClient.RespnoseKeys.ErrorDetail] as? String {
                                apiError = "\(apiError) errorDetail=\(errorDetail)"
                            }
                            completionHandler(success: false, result: nil, errorString: apiError)
                        }
                    } else {
                        completionHandler(success: false, result: nil, errorString: "Bad response code while searching \(key)")
                    }
                } else {
                    completionHandler(success: false, result: nil, errorString: "Bad response while searching \(key) no meta on response")
                }
            }
        }
    }
}
