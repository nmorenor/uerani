//
//  ImageCache.swift
//  Meme
//
//  Created by nacho on 5/25/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    
    private var inMeMoryCache = NSCache()
    static let sharedInstancee = ImageCache()
    let imagesDirectoryURL:NSURL = FoursquareClient.Constants.FOURSQUARE_CACHE_DIR.URLByAppendingPathComponent("images")
    
    class func sharedInstance() -> ImageCache {
        return sharedInstancee
    }
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        
        if let image = inMeMoryCache.objectForKey(identifier!) as? UIImage {
            return image
        }
        
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier:String) {
        let path = pathForIdentifier(identifier)
        
        if (image == nil) {
            inMeMoryCache.removeObjectForKey(path)
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {
            }
            return
        }
        
        inMeMoryCache.setObject(image!, forKey: path)
        
        let data = UIImagePNGRepresentation(image!)
        data!.writeToFile(path, atomically: true)
    }
    
    func pathForIdentifier(identifier: String) -> String {
        if !NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryURL.path!) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(imagesDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }
        let fullURL = imagesDirectoryURL.URLByAppendingPathComponent(identifier)
        return fullURL.path!
    }
}
