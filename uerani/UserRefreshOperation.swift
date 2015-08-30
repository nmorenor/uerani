//
//  UserRefreshOperation.swift
//  uerani
//
//  Created by nacho on 8/29/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

public protocol UserRefreshDelegate : class {
    
    func refreshUserData(user:CDUser)
    
    func refreshUserDataError(errorString:String)
}

public class UserRefreshOperation : AbstractCoreDataOperation {
    
    var refreshDelegate:UserRefreshDelegate?
    
    init(delegate:UserRefreshDelegate?) {
        self.refreshDelegate = delegate
        if LocationRequestManager.sharedInstance().userRefreshOperationQueue.operationCount == 0 {
            super.init(operationQueue: LocationRequestManager.sharedInstance().userRefreshOperationQueue)
        } else {
            super.init(operationQueue: nil)
        }
    }
    
    override public func main() {
        FoursquareClient.sharedInstance().loadUserData(self.userDataResponseHandler)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    func userDataResponseHandler(success:Bool, result:[String: AnyObject]?, errorString:String?) {
        if let error = errorString {
            self.refreshDelegate?.refreshUserDataError(error)
            self.unlock()
        } else {
            if let result = result {
                if let user:CDUser = self.getUserFromResponse(result) {
                    saveContext(self.sharedModelContext) { success in
                        self.refreshDelegate?.refreshUserData(user)
                        self.unlock()
                    }
                } else {
                    let user = CDUser(result: result, context: self.sharedModelContext)
                    saveContext(self.sharedModelContext) { success in
                        self.refreshDelegate?.refreshUserData(user)
                        self.unlock()
                    }
                }
            } else {
                self.refreshDelegate?.refreshUserDataError("Bad response data")
                self.unlock()
            }
        }
    }
    
    func getUserFromResponse(result:[String:AnyObject]?) -> CDUser? {
        if let result = result, userId = result[FoursquareClient.RespnoseKeys.ID] as? String {
            var request = NSFetchRequest(entityName: "CDUser")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.predicate = NSPredicate(format: "id == %@", userId)
            
            var error:NSError? = nil
            var cResult = self.sharedModelContext.executeFetchRequest(request, error: &error)
            if let error = error {
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
                                    var cPhoto = CDPhoto(data: photo, context: self.sharedModelContext)
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
}