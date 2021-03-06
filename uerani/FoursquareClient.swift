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
            let result: Bool
            do {
                try fileManager.createDirectoryAtURL(FoursquareClient.Constants.FOURSQUARE_CACHE_DIR, withIntermediateDirectories: false, attributes: nil)
                result = true
            } catch var error1 as NSError {
                error = error1
                result = false
            } catch {
                fatalError()
            }
            if !result && DEBUG {
                print("*** \(String(FoursquareClient.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not create directory to store cache data: \(error)")
            }
        }
        let targetFile = FoursquareClient.Constants.FOURSQUARE_CACHE_DIR.URLByAppendingPathComponent("cache.realm")
        if !fileManager.fileExistsAtPath(targetFile.path!) {
            let result = fileManager.createFileAtPath(targetFile.path!, contents: nil, attributes: nil)
            if !result && DEBUG {
                print("*** \(String(FoursquareClient.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not create file to store cache data")
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
        guard let token = accessToken else {
            do {
                try Locksmith.deleteDataForUserAccount("foursquare-client")
                self.inMemoryToken = nil
            } catch _ {}
            return
        }
        do {
            let data = ["access_token" : token]
            //save data on key chain
            try Locksmith.saveData(data, forUserAccount: "foursquare-client")
        
            self.inMemoryToken = token
        } catch _ {}
    }
    
    private func getAccessToken() -> String? {
        if let accessToken = self.inMemoryToken {
            return accessToken
        }
        //look for data on the key chain, do not store access token in plain text
        
        let lResult = Locksmith.loadDataForUserAccount("foursquare-client")
            guard let dictionary = lResult, let accessToken = dictionary["access_token"] as? String else {
                return nil
            }
        
        self.inMemoryToken = accessToken
        return accessToken
        
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
        if (url.scheme == "authuerani" && self.foursquareNativeAuthentication) {
            self.handleNativeAuthentication(url)
        }
    }
    
    //Mark - Foursquare Native authentication
    
    func handleNativeAuthentication(url:NSURL) {
        var errorCode:FSOAuthErrorCode = FSOAuthErrorCode.None
        let accessCode = FSOAuth.accessCodeForFSOAuthURL(url, error: &errorCode)
        
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
            accessTokenUrl: FoursquareClient.Constants.FOURSQUARE_ACCESS_TOKEN_URI,
            responseType:   "code"
        )
        let webViewController = WebViewController()
        oauthswift.authorize_url_handler = webViewController
        oauthswift.authorizeWithCallbackURL(NSURL(string: FoursquareClient.Constants.FOURSQUARE_CALLBACK_URI)!, scope: "", state: "", params: [String:String](), success: {credential, response, parameters in
                webViewController.dismissWebViewController()
                self.accessToken = credential.oauth_token
                delay(seconds: 0.4) {
                    self.accessTokenLoginDelegate?.successLogin()
                }
            
            }, failure: { _ in
                webViewController.dismissWebViewController()
                self.accessToken = nil
                self.accessTokenLoginDelegate?.errorLogin("Can not login to Foursquare")
        })
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
                let formatter = NSDateFormatter()
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
