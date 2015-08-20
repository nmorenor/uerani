//
//  FoursquareClient.swift
//  uerani
//
//  Created by nacho on 6/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import FSOAuth

public class FoursquareClient : HTTPClientProtocol {
    
    var httpClient:HTTPClient?
    var config = FoursquareConfig.unarchivedInstance() ?? FoursquareConfig()
    var accessCode:String?
    var oauthError:String?
    
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

        result[FoursquareClient.ParameterKeys.FOURSQUARE_OAUTH_TOKEN] = self.accessCode
        result[FoursquareClient.ParameterKeys.VERSION] = FoursquareClient.Constants.FORUSQUARE_VERSION
        
        return result
    }
    
    
    public func handleURL(url:NSURL) {
        if (url.scheme == "authuerani") {
            var errorCode:FSOAuthErrorCode = FSOAuthErrorCode.None
            var accessCode = FSOAuth.accessCodeForFSOAuthURL(url, error: &errorCode)
            
            if (errorCode == FSOAuthErrorCode.None) {
                self.accessCode = accessCode;
            }else {
                self.oauthError = self.errorMessageForCode(errorCode)
            }
        }
    }
    
    func errorMessageForCode(errorCode:FSOAuthErrorCode) -> String? {
        var resultText:String? = nil;
    
        switch (errorCode) {
            case FSOAuthErrorCode.None:
                break
        case FSOAuthErrorCode.InvalidClient:
                resultText = "Invalid client error"
                break
            case FSOAuthErrorCode.InvalidGrant:
                resultText = "Invalid grant error"
                break
            case FSOAuthErrorCode.InvalidRequest:
                resultText =  "Invalid request error"
                break
            case FSOAuthErrorCode.UnauthorizedClient:
                resultText =  "Invalid unauthorized client error"
                break
            case FSOAuthErrorCode.UnsupportedGrantType:
                resultText =  "Invalid unsupported grant error"
                break
            default:
                resultText =  "Unknown error"
                break
        
        }
    
        return resultText;
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> FoursquareClient {
        
        struct Singleton {
            static var sharedInstance = FoursquareClient()
        }
        
        return Singleton.sharedInstance
    }
}
