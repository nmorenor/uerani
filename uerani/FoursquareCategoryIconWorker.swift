//
//  FoursquareCategoryIconWorker.swift
//  uerani
//
//  Created by nacho on 7/20/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit

class FoursquareCategoryIconWorker: NSOperation, NSURLSessionDataDelegate {
   
    private var imageData:NSMutableData?
    private var totalBytes:Int = 0
    private var receivedBytes:Int = 0
    var session:NSURLSession!
    var prefix:String
    var suffix:String
    var currentIcon:NSURL?
    private var semaphore = dispatch_semaphore_create(0)
    
    init(prefix:String, suffix:String) {
        self.prefix = prefix
        self.suffix = suffix
        
        super.init()
        LocationRequestManager.sharedInstance().categoryIconOperationQueue.addOperation(self)
    }
    
    override func cancel() {
        super.cancel()
        self.totalBytes = 0
        self.receivedBytes = 0
        self.imageData = nil
        self.session = nil
    }
    
    override func main() {
        for nextSize in FIcon.FIconSize.allValues {
            var url = NSURL(string: "\(prefix)\(nextSize.description)\(suffix)")
            if let nextUrl = url {
                self.currentIcon = nextUrl
                let nextImage = ImageCache.sharedInstance().imageWithIdentifier(nextUrl.lastPathComponent!)
                if nextImage == nil {
                    self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: LocationRequestManager.sharedInstance().categoryIconOperationQueue)
                    self.download()
                    //wait for the download
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    self.session = nil
                }
            }
            self.currentIcon = nil
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    private func download() {
        let request = NSURLRequest(URL: self.currentIcon!)
        let dataTask = self.session.dataTaskWithRequest(request)
        
        dataTask.resume()
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if self.cancelled {
            return;
        }
        
        self.receivedBytes = 0
        self.totalBytes = Int(response.expectedContentLength);
        self.imageData = NSMutableData(capacity: self.totalBytes)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if self.cancelled {
            return;
        }
        
        self.imageData?.appendData(data)
        self.receivedBytes += data.length
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            println("Error downloading category icon \(error)")
        }
        if let imageData = self.imageData {
            let image = UIImage(data: imageData)
            ImageCache.sharedInstance().storeImage(image, withIdentifier: self.currentIcon!.lastPathComponent!)
        }
        self.totalBytes = 0
        self.receivedBytes = 0
        self.imageData = nil
        self.session = nil
        self.unlock()
    }
}
