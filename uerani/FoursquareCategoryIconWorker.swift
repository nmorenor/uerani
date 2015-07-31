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
    var regex:Regex = Regex(pattern: "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
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
            var nextStringURL = "\(prefix)\(nextSize.description)\(suffix)"
            var url = NSURL(string: nextStringURL)
            if let nextUrl = url where regex.test(nextStringURL) {
                self.currentIcon = nextUrl
                let pathComponents = nextUrl.pathComponents!
                let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
                var imageCacheName = "\(prefix_image_name)_\(nextUrl.lastPathComponent!)"
                let nextImage = ImageCache.sharedInstance().imageWithIdentifier(imageCacheName)
                if nextImage == nil {
                    self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: LocationRequestManager.sharedInstance().categoryIconDownloadOperationQueue)
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
            self.unlock()
            return;
        }
        
        self.receivedBytes = 0
        self.totalBytes = Int(response.expectedContentLength);
        self.imageData = NSMutableData(capacity: self.totalBytes)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if self.cancelled {
            self.unlock()
            return;
        }
        
        self.imageData?.appendData(data)
        self.receivedBytes += data.length
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let error = error {
            println("Error downloading category icon \(error)")
        } else {
            if let imageData = self.imageData {
                let image = UIImage(data: imageData)
                let pathComponents = self.currentIcon!.pathComponents!
                let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
                var imageCacheName = "\(prefix_image_name)_\(self.currentIcon!.lastPathComponent!)"
                ImageCache.sharedInstance().storeImage(image, withIdentifier: imageCacheName)
            }
        }
        self.totalBytes = 0
        self.receivedBytes = 0
        self.imageData = nil
        self.session = nil
        self.unlock()
    }
}
