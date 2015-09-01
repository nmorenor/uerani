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
                    var downloadImage = DownloadImageUtil(imageCacheName: imageCacheName, operationQueue: LocationRequestManager.sharedInstance().categoryIconDownloadOperationQueue, finishHandler: self.unlock)
                    downloadImage.performDownload(nextUrl)
                    
                    //wait for the download
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                }
            }
            self.currentIcon = nil
        }
    }
    
    private func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
}
