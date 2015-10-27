//
//  DownloadImageUtil.swift
//  uerani
//
//  Created by nacho on 8/31/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class DownloadImageUtil : NSObject, NSURLSessionDataDelegate {
    
    typealias UnlockHandler = () -> ()
    
    private var imageData:NSMutableData?
    private var totalBytes:Int = 0
    private var receivedBytes:Int = 0
    var session:NSURLSession!
    var imageCacheName:String?
    var finishHandler:UnlockHandler?
    var operationQueue:NSOperationQueue
    
    init(imageCacheName:String, operationQueue:NSOperationQueue, finishHandler:UnlockHandler?) {
        self.imageCacheName = imageCacheName
        self.finishHandler = finishHandler
        self.operationQueue = operationQueue
    }
    
    public func performDownload(url:NSURL) {
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: operationQueue)
        let request = NSURLRequest(URL: url)
        let dataTask = self.session.dataTaskWithRequest(request)
        
        dataTask.resume()
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        self.receivedBytes = 0
        self.totalBytes = Int(response.expectedContentLength);
        self.imageData = NSMutableData(capacity: self.totalBytes)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        self.imageData?.appendData(data)
        self.receivedBytes += data.length
    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            if DEBUG {
                Swift.print("Error downloading category icon \(error)", terminator: "")
            }
        } else {
            if let imageData = self.imageData {
                let image = UIImage(data: imageData)
                ImageCache.sharedInstance().storeImage(image, withIdentifier: self.imageCacheName!)
            }
        }
        self.totalBytes = 0
        self.receivedBytes = 0
        self.imageData = nil
        self.session = nil
        if let handler = self.finishHandler {
            handler()
        }
    }
}
