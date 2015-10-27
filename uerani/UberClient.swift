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
    var httpClient:HTTPClient?
    weak var accessTokenLoginDelegate:AccessTokenLoginDelegate? = nil
    
    var accessToken:String? {
        get {
            return self.getAccessToken()
        }
    }
    var oauthError:String? {
        didSet {
            //do something
        }
    }
    
    init() {
        self.httpClient = HTTPClient(delegate: self)
    }
    
    public func getBaseURLSecure() -> String {
        return UberClient.Constants.BASE_URL
    }
    
    func setInMemoryToken(data:[String:String]?) {
        self.saveToKeyChain(data)
        if let data = data {
            self.inMemoryToken = data["access_token"]
        } else {
            self.inMemoryToken = nil
        }
        
    }
    
    private func saveToKeyChain(saveData:[String:String]?) {
        do {
            guard let data = saveData else {
                do {
                    try Locksmith.deleteDataForUserAccount("uber-client-\(FoursquareClient.sharedInstance().userId!)")
                } catch _ {}
                return
            }
            //save data on key chain
            try Locksmith.saveData(data, forUserAccount: "uber-client-\(FoursquareClient.sharedInstance().userId!)")
        } catch _ {
            
        }
    }
    
    private func getAccessToken() -> String? {
        if let accessToken = self.inMemoryToken {
            return accessToken
        }
        //look for data on the key chain, do not store access token in plain text

        let locksmithResult = Locksmith.loadDataForUserAccount("uber-client-\(FoursquareClient.sharedInstance().userId!)")
        guard let dictionary = locksmithResult, let accessToken = dictionary["access_token"] as? String else  {
            return nil
        }
        
        self.inMemoryToken = accessToken
        return accessToken
    }
    
    public func addRequestHeaders(request: NSMutableURLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(self.accessToken!)", forHTTPHeaderField: "Authorization")
    }
    
    public func processJsonBody(jsonBody: [String : AnyObject]) -> [String : AnyObject] {
        return jsonBody
    }
    
    public func processResponse(data: NSData) -> NSData {
        return data
    }
    
    public func addAuthParameters(parameters:[String:AnyObject]) -> [String:AnyObject] {
        let result = parameters
        return result
    }
    
    //MARK: - OAuthSwiftAuth
    
    public func handleWebLogin() {
        let oauthswift = OAuth2Swift(
            consumerKey:    UberClient.Constants.UBER_CLIENT_ID,
            consumerSecret: UberClient.Constants.UBER_SECRET,
            authorizeUrl:   UberClient.Constants.UBER_AUTHORIZE_URI,
            accessTokenUrl: UberClient.Constants.UBER_TOKEN_URI,
            responseType:   "code",
            contentType:    "multipart/form-data"
        )
        let state: String = generateStateWithLength(20) as String
        let redirectURL = UberClient.Constants.UBER_CALLBACK_URI.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        let webViewController = WebViewController()
        oauthswift.authorize_url_handler = webViewController
        oauthswift.authorizeWithCallbackURL(NSURL(string: redirectURL!)!, scope: "profile", state: state, params: [String:String](), success: { credential, response, parameters in
                webViewController.dismissWebViewController()
                var data = [String:String]()
                if let refreshToken = parameters["refresh_token"] as? String {
                    data["refresh_token"] = refreshToken
                }
                data["access_token"] = credential.oauth_token
                self.setInMemoryToken(data)
                delay(seconds: 0.4) {
                    self.accessTokenLoginDelegate?.successLogin()
                }
            
            }, failure: { _ in
                webViewController.dismissWebViewController()
                self.accessTokenLoginDelegate?.errorLogin("Can not login to uber")
        })
        
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> UberClient {
        return instance
    }
}