//
//  FoursquareClient.swift
//  uerani
//
//  Created by nacho on 6/6/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import FSOAuth
import OAuthSwift
import Locksmith

public class FoursquareClient : HTTPClientProtocol, WebTokenDelegate {
    
    static var instance = FoursquareClient()
    var httpClient:HTTPClient?
    var config = FoursquareConfig.unarchivedInstance() ?? FoursquareConfig()
    var userId:String? {
        set (value) {
            self.config.addValue(FoursquareClient.Constants.FOURSQUARE_USER_ID, value: value)
        }
        get {
            return self.config.getValue(FoursquareClient.Constants.FOURSQUARE_USER_ID)
        }
    }
    private var inMemoryToken:String?
    var accessToken:String? {
        get {
            return self.getAccessToken()
        }
        
        set (accessToken) {
            self.setInMemoryToken(accessToken)
        }
    }
    var oauthError:String? {
        didSet {
            //do something
        }
    }
    
    lazy var foursquareDataCacheRealmFile:NSURL = { [unowned self] in
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(FoursquareClient.Constants.FOURSQUARE_CACHE_DIR.path!) {
            var error:NSError?
            let result = fileManager.createDirectoryAtURL(FoursquareClient.Constants.FOURSQUARE_CACHE_DIR, withIntermediateDirectories: false, attributes: nil, error: &error)
            if !result {
                println("*** \(toString(FoursquareClient.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not create directory to store cache data: \(error)")
            }
        }
        let targetFile = FoursquareClient.Constants.FOURSQUARE_CACHE_DIR.URLByAppendingPathComponent("cache.realm")
        if !fileManager.fileExistsAtPath(targetFile.path!) {
            let result = fileManager.createFileAtPath(targetFile.path!, contents: nil, attributes: nil)
            if !result {
                println("*** \(toString(FoursquareClient.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not create file to store cache data")
            }
        }
        
        return targetFile
    }()
    
    var foursquareNativeAuthentication:Bool = false
    weak var accessTokenLoginDelegate:AccessTokenLoginDelegate? = nil
    
    init() {
        self.httpClient = HTTPClient(delegate: self)
    }
    
    private func setInMemoryToken(accessToken:String?) {
        if let accessToken = accessToken {
            var data = ["access_token" : accessToken]
            //save data on key chain
            Locksmith.saveData(data, forUserAccount: "foursquare-client")
        } else {
            Locksmith.deleteDataForUserAccount("foursquare-client")
        }
        self.inMemoryToken = accessToken
    }
    
    private func getAccessToken() -> String? {
            if let accessToken = self.inMemoryToken {
                return accessToken
            }
            //look for data on the key chain, do not store access token in plain text
            let (dictionary, error) = Locksmith.loadDataForUserAccount("foursquare-client")
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

        result[FoursquareClient.ParameterKeys.FOURSQUARE_OAUTH_TOKEN] = self.accessToken!
        result[FoursquareClient.ParameterKeys.VERSION] = FoursquareClient.Constants.FORUSQUARE_VERSION
        result[FoursquareClient.ParameterKeys.M] = FoursquareClient.Constants.FOURSQUARE
        
        return result
    }
    
    public func handleURL(url:NSURL) {
        if (url.scheme == "authuerani") {
            if self.foursquareNativeAuthentication {
                self.handleNativeAuthentication(url)
            } else {
                self.handleWebAuthentication(url)
            }
        }
    }
    
    func handleWebAuthentication(url:NSURL) {
        var responseParameters: Dictionary<String, String> = Dictionary()
        if let query = url.query {
            responseParameters = query.parametersFromQueryString()
        }
        if ((url.fragment) != nil && url.fragment!.isEmpty == false) {
            var fragmentParameters = url.fragment!.parametersFromQueryString()
            for nextKey in fragmentParameters.keys {
                responseParameters[nextKey] = fragmentParameters[nextKey]
            }
        }
        if let accessCode = responseParameters["code"] {
            self.getAccessToken(accessCode)
        } else {
            self.oauthError = "Error while login in to Foursquare"
            self.accessTokenLoginDelegate?.errorLogin(self.oauthError)
        }
    }
    
    //Mark - Foursquare Native authentication
    
    func handleNativeAuthentication(url:NSURL) {
        var errorCode:FSOAuthErrorCode = FSOAuthErrorCode.None
        var accessCode = FSOAuth.accessCodeForFSOAuthURL(url, error: &errorCode)
        
        if (errorCode == FSOAuthErrorCode.None) {
            self.getAccessToken(accessCode)
        } else {
            self.oauthError = self.errorMessageForCode(errorCode)
            self.accessTokenLoginDelegate?.errorLogin(self.oauthError)
        }
        
    }
    
    func getAccessToken(accessCode:String) {
        FSOAuth.requestAccessTokenForCode(accessCode, clientId: FoursquareClient.Constants.FOURSQUARE_CLIENT_ID, callbackURIString: FoursquareClient.Constants.FOURSQUARE_CALLBACK_URI, clientSecret: FoursquareClient.Constants.FOURSQUARE_SECRET) { authToken, requestCompleted, errorCode in
            if (requestCompleted) {
                if let errorMessage = self.errorMessageForCode(errorCode) {
                    self.oauthError = errorMessage
                    self.accessTokenLoginDelegate?.errorLogin(self.oauthError)
                } else {
                    self.accessToken = authToken
                    self.accessTokenLoginDelegate?.successLogin()
                }
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
    
    //MARK: - OAuthSwiftAuth
    
    public func handleWebLogin() {
        let oauthswift = OAuth2Swift(
            consumerKey:    FoursquareClient.Constants.FOURSQUARE_CLIENT_ID,
            consumerSecret: FoursquareClient.Constants.FOURSQUARE_SECRET,
            authorizeUrl:   FoursquareClient.Constants.FOURSQUARE_AUTHORIZE_URI,
            responseType:   "code"
        )
        oauthswift.authorizeWithCallbackURL(NSURL(string: FoursquareClient.Constants.FOURSQUARE_CALLBACK_URI)!, scope: "", state: "", params: [String:String](), success: {_ in }, failure: { _ in })
        
    }
    
    // MARK: - Shared Instance
    
    public class func sharedInstance() -> FoursquareClient {
        return instance
    }
    
    // MARK: - Shared Date Formatter
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                var formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-mm-dd"
                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
}

extension String {
    
    func parametersFromQueryString() -> Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = NSScanner(string: self)
        
        var key: NSString?
        var value: NSString?
        
        while !scanner.atEnd {
            key = nil
            scanner.scanUpToString("=", intoString: &key)
            scanner.scanString("=", intoString: nil)
            
            value = nil
            scanner.scanUpToString("&", intoString: &value)
            scanner.scanString("&", intoString: nil)
            
            if (key != nil && value != nil) {
                parameters.updateValue(value! as String, forKey: key! as String)
            }
        }
        
        return parameters
    }
    
}
