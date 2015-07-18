//
//  FoursquareClient.swift
//  grabbed
//
//  Created by nacho on 6/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class FoursquareClient : HTTPClientProtocol {
    
    var httpClient:HTTPClient?
    var config = FoursquareConfig.unarchivedInstance() ?? FoursquareConfig()
    
    init() {
        self.httpClient = HTTPClient(delegate: self)
    }
    
    public func getBaseURLSecure() -> String {
        return FoursquareClient.Constants.BASE_URL
    }
    
    public func addRequestHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    public func processJsonBody(jsonBody: [String : AnyObject]) -> [String : AnyObject] {
        return jsonBody
    }
    
    public func processResponse(data: NSData) -> NSData {
        return data
    }
    
    public func addAuthParameters(parameters:[String:AnyObject]) -> [String:AnyObject] {
        var result = parameters

        result[FoursquareClient.ParameterKeys.CLIENT_ID] = FoursquareClient.Constants.FOURSQUARE_CLIENT_ID
        result[FoursquareClient.ParameterKeys.CLIENT_SECRET] = FoursquareClient.Constants.FOURSQUARE_SECRET
        result[FoursquareClient.ParameterKeys.VERSION] = FoursquareClient.Constants.FORUSQUARE_VERSION
        
        return result
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> FoursquareClient {
        
        struct Singleton {
            static var sharedInstance = FoursquareClient()
        }
        
        return Singleton.sharedInstance
    }
}
