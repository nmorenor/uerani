//
//  VenueDetailOperation.swift
//  uerani
//
//  Created by nacho on 9/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol VenueDetailsDelegate : class {
    
    func refreshVenueDetails(venueId:String)
    
    func refreshVenueDetailsError(errorString:String)
}

public class VenueDetailOperation:NSOperation {
    
    var venueId:String
    var size:String
    weak var venueDetailDelegate:VenueDetailsDelegate?
    var semaphore = dispatch_semaphore_create(0)
    var imageSemaphore = dispatch_semaphore_create(0)
    var success = false
    
    init(venueId:String, imageSize:CGSize, delegate:VenueDetailsDelegate?) {
        self.venueId = venueId
        self.venueDetailDelegate = delegate
        self.size = "\(imageSize.width.getIntValue())x\(((imageSize.height/2) * 1.15).getIntValue())"
        super.init()
        //schedule the operation
        NSOperationQueue().addOperation(self)
    }
    
    override public func main() {
        FoursquareClient.sharedInstance().getVenueDetail(self.venueId, completionHandler: self.foursquareClientHandler)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        if success {
            self.downloadImageAndNotify()
        }
    }
    
    private func downloadImageAndNotify() {
        let realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        if let venue = realm.objectForPrimaryKey(FVenue.self, key: venueId) {
            var photo:FPhoto?
            if let bestPhoto = venue.bestPhoto {
                photo = bestPhoto
            } else if let fphoto = venue.photos.first {
                photo = fphoto
                realm.write() {
                    realm.add(venue, update: true)
                }
            }
            
            self.downloadPhoto(photo)
            
            self.venueDetailDelegate?.refreshVenueDetails(self.venueId)
        } else {
            self.venueDetailDelegate?.refreshVenueDetailsError("Error retriving data from local storage")
        }
    }
    
    private func downloadPhoto(photo:FPhoto?) {
        if let photo = photo {
            var identifier = getImageIdentifier(self.size, photo)
            var photoURL = "\(photo.prefix)\(self.size)\(photo.suffix)"
            if let url = NSURL(string: photoURL), let identifier = identifier {
                var imageCacheName = "venue_\(self.venueId)_\(identifier)"
                let nextImage = ImageCache.sharedInstance().imageWithIdentifier(imageCacheName)
                
                if nextImage == nil {
                    var downloadImage = DownloadImageUtil(imageCacheName: imageCacheName, operationQueue: NSOperationQueue(), finishHandler: self.unlockImage)
                    downloadImage.performDownload(url)
                    //wait for the download
                    dispatch_semaphore_wait(imageSemaphore, DISPATCH_TIME_FOREVER)
                }
            }
        }
    }
    
    private func foursquareClientHandler(success:Bool, result:[String:AnyObject]?, errorString:String?) {
        if let error = errorString {
            self.venueDetailDelegate?.refreshVenueDetailsError(error)
        } else if success {
            if let result = result {
                let realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
                var venue:FVenue!
                realm.write {
                    //update venue with data from foursquare
                    venue = realm.create(FVenue.self, value: result, update: true)
                    
                    //mark as complete venue
                    venue.completeVenue = true
                    realm.add(venue, update: true)
                }
                self.success = true
            } else {
                self.venueDetailDelegate?.refreshVenueDetailsError("Error while doing Foursquare data request")
            }
        } else {
            self.venueDetailDelegate?.refreshVenueDetailsError("Error while doing Foursquare data request")
        }
        self.unlock()
    }
    
    func unlock() {
        dispatch_semaphore_signal(semaphore)
    }
    
    func unlockImage() {
        dispatch_semaphore_signal(imageSemaphore)
    }
}

extension CGFloat {
    
    func getIntValue() -> Int {
        return Int(self)
    }
}
