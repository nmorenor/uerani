//
//  VenueDetailOperation.swift
//  uerani
//
//  Created by nacho on 9/4/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

public protocol VenueDetailsDelegate : class {
    
    func refreshVenueDetails(venueId:String)
    
    func refreshVenueDetailsError(errorString:String)
}

public class VenueDetailOperation:AbstractCoreDataOperation {
    
    var venueId:String
    var size:String
    weak var venueDetailDelegate:VenueDetailsDelegate?
    var completeVenueSemaphore = dispatch_semaphore_create(0)
    var imageSemaphore = dispatch_semaphore_create(0)
    var success = false
    var updateCoreData:Bool
    
    init(venueId:String, imageSize:CGSize, updateCoreData:Bool, delegate:VenueDetailsDelegate?) {
        self.venueId = venueId
        self.venueDetailDelegate = delegate
        self.updateCoreData = updateCoreData
        self.size = "\(imageSize.width.getIntValue())x\(((imageSize.height/2) * 1.15).getIntValue())"
        super.init(operationQueue: NSOperationQueue())
    }
    
    override public func main() {
        FoursquareClient.sharedInstance().getVenueDetail(self.venueId, completionHandler: self.foursquareClientHandler)
        dispatch_semaphore_wait(completeVenueSemaphore, DISPATCH_TIME_FOREVER)
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
            
            if self.updateCoreData {
                let fetchRequest = NSFetchRequest(entityName: "CDVenue")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "id = %@", venue.id)
                
                var error:NSError? = nil
                var results = self.sharedModelContext.executeFetchRequest(fetchRequest, error: &error)
                var result:CDVenue!
                if let error = error {
                    println("can not find venue \(venue.id)")
                    result = CDVenue(venue: venue, context: self.sharedModelContext)
                } else if let results = results where !results.isEmpty {
                    result = results.first as! CDVenue
                } else {
                    result = CDVenue(venue: venue, context: self.sharedModelContext)
                }
                CDVenue.updateVenue(result, venue: venue, context: self.sharedModelContext)
                
                saveContext(self.sharedModelContext) { success in
                    //do nothing
                }
                //wait to merge main context
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
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
        self.unlockCompleteVenue()
    }
    
    func unlockCompleteVenue() {
        dispatch_semaphore_signal(completeVenueSemaphore)
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
