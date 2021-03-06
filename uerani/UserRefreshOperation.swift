//
//  UserRefreshOperation.swift
//  uerani
//
//  Created by nacho on 8/29/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public protocol UserRefreshDelegate : class {
    
    func refreshUserData(user:CDUser)
    
    func refreshUserDataError(errorString:String)
}

public class UserRefreshOperation : AbstractCoreDataOperation {
    
    var refreshDelegate:UserRefreshDelegate?
    var user:CDUser?
    var imageSemaphore = dispatch_semaphore_create(0)
    
    init(delegate:UserRefreshDelegate?) {
        self.refreshDelegate = delegate
        super.init(operationQueue: LocationRequestManager.sharedInstance().userRefreshOperationQueue)
    }
    
    override public func main() {
        FoursquareClient.sharedInstance().loadUserData(self.userDataResponseHandler)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        self.createFavoriteListIfNeeded()
        self.downloadUserPhoto(self.user)
        if let user = self.user {
            FoursquareClient.sharedInstance().userId = user.id
            self.refreshDelegate?.refreshUserData(user)
        }
    }
    
    func createFavoriteListIfNeeded() {
        if let user = self.user {
            let request = NSFetchRequest(entityName: "CDVenueList")
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]
            request.predicate = NSPredicate(format: "ANY user == %@", user)
            
            var error:NSError? = nil
            var result: [AnyObject]?
            do {
                result = try self.sharedModelContext.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                result = nil
            }
            if let _ = error {
                print("Can not find favorite list for user")
            } else {
                var createFavoriteList = true
                if let result = result {
                    if !result.isEmpty {
                        createFavoriteList = false
                    }
                }
                if createFavoriteList {
                    _ = CDVenueList(title: "Favorites", user: user, context: self.sharedModelContext)
                    saveContext(self.sharedModelContext) { success in
                        //do nothing
                    }
                }
            }
        }
    }
    
    func userDataResponseHandler(success:Bool, result:[String: AnyObject]?, errorString:String?) {
        if let error = errorString {
            self.refreshDelegate?.refreshUserDataError(error)
            self.unlock()
        } else {
            if let result = result {
                if let user:CDUser = self.getUserFromResponse(result) {
                    saveContext(self.sharedModelContext) { success in
                        self.user = user
                        self.unlock()
                    }
                } else {
                    let user = CDUser(result: result, context: self.sharedModelContext)
                    saveContext(self.sharedModelContext) { success in
                        self.user = user
                        self.unlock()
                    }
                }
            } else {
                self.refreshDelegate?.refreshUserDataError("Bad response data")
                self.unlock()
            }
        }
    }
    
    func downloadUserPhoto(user:CDUser?) {
        if let user = user {
            if let photo = user.photo {
                let photoURL = "\(photo.prefix)100x100\(photo.suffix)"
                if let url = NSURL(string: photoURL) {
                    let imageCacheName = "user_\(user.id)_\(getImageIdentifier(url)!)"
                    let nextImage = ImageCache.sharedInstance().imageWithIdentifier(imageCacheName)
                    
                    if nextImage == nil {
                        let downloadImage = DownloadImageUtil(imageCacheName: imageCacheName, operationQueue: LocationRequestManager.sharedInstance().userRefreshOperationQueue, finishHandler: self.unlockDownload)
                        downloadImage.performDownload(url)
                        //wait for the download
                        dispatch_semaphore_wait(imageSemaphore, DISPATCH_TIME_FOREVER)
                    }
                }
            }
        }
    }
    
    func getUserFromResponse(result:[String:AnyObject]?) -> CDUser? {
        if let result = result, userId = result[FoursquareClient.RespnoseKeys.ID] as? String {
            let request = NSFetchRequest(entityName: "CDUser")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.predicate = NSPredicate(format: "id == %@", userId)
            
            var error:NSError? = nil
            var cResult: [AnyObject]?
            do {
                cResult = try self.sharedModelContext.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                cResult = nil
            }
            if let _ = error {
                self.refreshDelegate?.refreshUserDataError("Can not update user data")
            } else {
                if let cResult = cResult {
                    for next in cResult {
                        if let user = next as? CDUser {
                            if let firstName = result[FoursquareClient.RespnoseKeys.FIRST_NAME] as? String {
                                user.firstName = firstName
                            } else {
                                user.firstName = ""
                            }
                            if let lastName = result[FoursquareClient.RespnoseKeys.LAST_NAME] as? String {
                                user.lastName = lastName
                            } else {
                                user.lastName = ""
                            }
                            if let homeCity = result[FoursquareClient.RespnoseKeys.HOME_CITY] as? String {
                                user.homeCity = homeCity
                            } else {
                                user.homeCity = ""
                            }
                            if let gender = result[FoursquareClient.RespnoseKeys.GENDER] as? String {
                                user.gender = gender
                            } else {
                                user.gender = ""
                            }
                            if let photo = result[FoursquareClient.RespnoseKeys.PHOTO] as? [String:AnyObject] {
                                if let cPhoto = user.photo {
                                    cPhoto.prefix = photo[FoursquareClient.RespnoseKeys.PREFIX] as! String
                                    cPhoto.suffix = photo[FoursquareClient.RespnoseKeys.SUFFIX] as! String
                                } else {
                                    let cPhoto = CDPhoto(data: photo, context: self.sharedModelContext)
                                    cPhoto.user = user
                                    user.photo = cPhoto
                                }
                            } else {
                                if let photo = user.photo {
                                    user.photo = nil
                                    self.sharedModelContext.deleteObject(photo)
                                }
                            }
                            user.lastUpdate = NSDate()
                        
                            return user
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func unlockDownload() {
        dispatch_semaphore_signal(imageSemaphore)
    }
}