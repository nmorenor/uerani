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
    var size:String?
    weak var venueDetailDelegate:VenueDetailsDelegate?
    var completeVenueSemaphore = dispatch_semaphore_create(0)
    var imageSemaphore = dispatch_semaphore_create(0)
    var success = false
    var updateCoreData:Bool
    var venueListName:String?
    var refreshFoursquareData:Bool
    
    init(venueId:String, refreshFoursquareData:Bool, imageSize:CGSize?, updateCoreData:Bool, venueListName:String?, delegate:VenueDetailsDelegate?) {
        self.venueId = venueId
        self.venueDetailDelegate = delegate
        self.updateCoreData = updateCoreData
        self.refreshFoursquareData = refreshFoursquareData
        self.venueListName = venueListName
        if let imageSize = imageSize {
            self.size = "\(imageSize.width.getIntValue())x\(((imageSize.height/2) * 1.15).getIntValue())"
        }
        super.init(operationQueue: NSOperationQueue())
    }
    
    convenience init(venueId:String, imageSize:CGSize?, updateCoreData:Bool, delegate:VenueDetailsDelegate?) {
        self.init(venueId: venueId, refreshFoursquareData: true, imageSize:imageSize, updateCoreData: false, venueListName:nil, delegate:delegate)
    }
    
    convenience init(venueId:String, venueListName:String, delegate:VenueDetailsDelegate?) {
        self.init(venueId: venueId, refreshFoursquareData: false, imageSize:nil, updateCoreData: true, venueListName:venueListName, delegate:delegate)
        
    }
    
    override public func main() {
        if refreshFoursquareData {
            FoursquareClient.sharedInstance().getVenueDetail(self.venueId, completionHandler: self.foursquareClientHandler)
            dispatch_semaphore_wait(completeVenueSemaphore, DISPATCH_TIME_FOREVER)
        } else {
            self.success = true
        }
        
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
                self.updateCoreDataModel(venue)
            }
            if let size = self.size {
                self.downloadPhoto(size, photo: photo)
            }
            
            self.venueDetailDelegate?.refreshVenueDetails(self.venueId)
        } else {
            self.venueDetailDelegate?.refreshVenueDetailsError("Error retriving data from local storage")
        }
    }
    
    private func updateCoreDataModel(venue:FVenue) {
        let fetchRequest = NSFetchRequest(entityName: "CDVenue")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id = %@", venue.id)
        
        var error:NSError? = nil
        var results = self.sharedModelContext.executeFetchRequest(fetchRequest, error: &error)
        var result:CDVenue!
        if let error = error {
            if DEBUG {
                println("can not find venue \(venue.id)")
            }
            result = CDVenue(venue: venue, context: self.sharedModelContext)
        } else if let results = results where !results.isEmpty {
            result = results.first as! CDVenue
        } else {
            result = CDVenue(venue: venue, context: self.sharedModelContext)
        }
        CDVenue.updateVenue(result, venue: venue, context: self.sharedModelContext)
        
        if let venueName = self.venueListName {
            let fetchRequest = NSFetchRequest(entityName: "CDVenueList")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "user.id == %@ AND title == %@", FoursquareClient.sharedInstance().userId!, venueName)
            
            var error:NSError?
            var venueListResults = self.sharedModelContext.executeFetchRequest(fetchRequest, error: &error)
            if let error = error {
                if DEBUG {
                    println("can not find venue List \(venue.id) :: \(venueName)")
                }
            } else if let venueListResults = venueListResults where !venueListResults.isEmpty {
                var list = venueListResults.first as! CDVenueList
                list.venues.addObject(result)
                result.venueLists.addObject(list)
            }
        }
        
        saveContext(self.sharedModelContext) { success in
            //do nothing
        }
        //wait to merge main context
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    private func downloadPhoto(size : String, photo:FPhoto?) {
        if let photo = photo {
            var identifier = getImageIdentifier(size, photo)
            var photoURL = "\(photo.prefix)\(size)\(photo.suffix)"
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
