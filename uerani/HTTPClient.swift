//
//  HTTPClient.swift
//  On The Map
//
//  Created by nacho on 5/1/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

let DEBUG = false

public class HTTPClient: NSObject {
    
    struct Constants {
        static let DateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
    }
    
    /* Shared session */
    var session:NSURLSession
    var delegate:HTTPClientProtocol!
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    convenience init(delegate:HTTPClientProtocol) {
        self.init()
        self.delegate = delegate
    }
    
    func taskWithBodyMethod(httpMethod:String, method: String, parameters: [String:AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var mutableJsonBody = self.delegate.processJsonBody(jsonBody)
        
        let urlString = self.delegate.getBaseURLSecure() + method + HTTPClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError:NSError? = nil
        self.delegate.addRequestHeaders(request)
        request.HTTPMethod = httpMethod
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(mutableJsonBody, options: nil, error: &jsonifyError)
        
        if (DEBUG && jsonifyError == nil) {
            println(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            let newData = self.delegate.processResponse(data)
            if (DEBUG) {
                println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
            if let error = downloadError {
                let newError = HTTPClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                HTTPClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return taskWithBodyMethod("POST", method: method, parameters: parameters, jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    // MARK: - PUT
    
    func taskForPUTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return taskWithBodyMethod("PUT", method: method, parameters: parameters, jsonBody: jsonBody, completionHandler: completionHandler)
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method:String, parameters:[String:AnyObject], completionHandler: (result:AnyObject!, error:NSError?) -> Void) -> NSURLSessionDataTask {
        
        let urlString:String! = self.delegate.getBaseURLSecure() + method + HTTPClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        self.delegate.addRequestHeaders(request)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            let newData = self.delegate.processResponse(data)
            if (DEBUG) {
                println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
            if let error = downloadError {
                let newError = HTTPClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                HTTPClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task;
    }
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error:NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String:AnyObject] {
            if let errorMessage = parsedResult[HTTPClient.JSONResponseKeys.ErrorMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey: errorMessage]
                if let errorCode = parsedResult[HTTPClient.JSONResponseKeys.Status] as? Int {
                    return NSError(domain: "Client Error", code: errorCode, userInfo: userInfo)
                } else {
                    return NSError(domain: "Client Error", code: 1, userInfo: userInfo)
                }
            }
        }
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    class func substituteKeyInMethod(method:String, key:String, value: String) -> String? {
        if (method.rangeOfString("{\(key)}") != nil) {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
}