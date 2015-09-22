//
//  UberClient.swift
//  uerani
//
//  Created by nacho on 9/19/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import OAuthSwift
import Locksmith

public class UberClient : HTTPClientProtocol {
    
    static var instance = UberClient()
    private var inMemoryToken:String?
    weak var accessTokenLoginDelegate:AccessTokenLoginDelegate? = nil
    
    var accessToken:String? {
        get {
            return self.getAccessToken()
        }
        
        set (accessToken) {
            self.setInMemoryToken("access_token", accessToken: accessToken)
        }
    }
    var oauthError:String? {
        didSet {
            //do something
        }
    }
    
    public func getBaseURLSecure() -> String {
        return FoursquareClient.Constants.BASE_URL
    }
    
    private func setInMemoryToken(key:String, accessToken:String?) {
        self.saveToKeyChain(key, data: accessToken)
        self.inMemoryToken = accessToken
    }
    
    private func saveToKeyChain(key:String, data:String?) {
        if let data = data {
            var data = [key : data]
            let (dictionary, error) = Locksmith.loadDataForUserAccount("uber-client-\(FoursquareClient.sharedInstance().userId!)")
            if let dictionary = dictionary {
                for key in dictionary.allKeys {
                    if let nextKey = key as? String {
                        if let nextValue = dictionary.valueForKey(nextKey) as? String {
                            data[nextKey] = nextValue
                        }
                    }
                }
            }
            //save data on key chain
            Locksmith.saveData(data, forUserAccount: "uber-client-\(FoursquareClient.sharedInstance().userId!)")
        } else {
            Locksmith.deleteDataForUserAccount("uber-client-\(FoursquareClient.sharedInstance().userId!)")
        }
    }
    
    private func getAccessToken() -> String? {
        if let accessToken = self.inMemoryToken {
            return accessToken
        }
        //look for data on the key chain, do not store access token in plain text
        let (dictionary, error) = Locksmith.loadDataForUserAccount("uber-client-\(FoursquareClient.sharedInstance().userId!)")
        if error != nil {
            println("*** \(toString(FoursquareClient.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not load access token from keychain \(error)")
            return nil
        }
        if let dictionary = dictionary {
            if let accessToken = dictionary["access_token"] as? String {
                self.inMemoryToken = accessToken
                return accessToken
            }
        }
        return nil
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
        
        result[FoursquareClient.ParameterKeys.FOURSQUARE_OAUTH_TOKEN] = self.accessToken!
        
        return result
    }
    
    //MARK: - OAuthSwiftAuth
    
    public func handleWebLogin() {
        let oauthswift = OAuth2Swift(
            consumerKey:    UberClient.Constants.UBER_CLIENT_ID,
            consumerSecret: UberClient.Constants.UBER_SECRET,
            authorizeUrl:   UberClient.Constants.UBER_AUTHORIZE_URI,
            responseType:   "code"
        )
        oauthswift.authorizeWithCallbackURL(NSURL(string: UberClient.Constants.UBER_CALLBACK_URI)!, scope: "", state: "", params: [String:String](), success: { credential, response, parameters in
                if let refreshToken = parameters["refresh_token"] as? String {
                    self.saveToKeyChain("refresh_token", data: refreshToken)
                }
                self.setInMemoryToken("access_token", accessToken: credential.oauth_token)
                self.accessTokenLoginDelegate?.successLogin()
            }, failure: { _ in
                self.accessTokenLoginDelegate?.errorLogin("Can not login to uber")
        })
        
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> UberClient {
        return instance
    }
}