//
//  UserViewModel.swift
//  uerani
//
//  Created by nacho on 9/2/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import QuartzCore
import UIKit

class UserViewModel {
    
    var name:String!
    var imageIdentifier:String?
    var width:CGFloat = 0.0
    let fontName = "HelveticaNeue"
    let fontSize:CGFloat = 14.0
    
    var image:UIImage {
        get {
            if let image = ImageCache.sharedInstance().imageWithIdentifier(self.imageIdentifier) {
                return image
            }
            return UIImage(named: "user")!.resizeImageWithScale(2.8)
        }
        
    }
    
    init(context:NSManagedObjectContext) {
        self.populate(context)
    }
    
    private func populate(context:NSManagedObjectContext) {
        if let userId = FoursquareClient.sharedInstance().userId {
            let request = NSFetchRequest(entityName: "CDUser")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.predicate = NSPredicate(format: "id == %@", userId)
            
            var error:NSError? = nil
            var cResult: [AnyObject]?
            do {
                cResult = try context.executeFetchRequest(request)
            } catch let error1 as NSError {
                error = error1
                cResult = nil
            }
            if let error = error {
                if DEBUG {
                    Swift.print("*** \(String(UserViewModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not load user data from core data: \(error)")
                    self.setDefaults()
                }
            } else if let result = cResult where result.count > 0 {
                let user = result.first! as! CDUser
                self.loadUserData(user, context: nil)
            } else {
                self.setDefaults()
            }
        } else {
            self.setDefaults()
        }
    }
    
    func loadUserData(data:CDUser, context: NSManagedObjectContext?) {
        var user:CDUser!
        if let context = context {
            user = context.objectWithID(data.objectID) as! CDUser
        } else {
            user = data
        }
        self.name = "\(user.firstName) \(user.lastName)"
        let font = UIFont(name: fontName, size: fontSize)!
        let attributedString = NSAttributedString(string:name, attributes: [NSFontAttributeName : font])
        let asize:CGSize = attributedString.size()
        
        self.width  = asize.width > 100 ? asize.width : 100
        
        let identifier = getImageIdentifier("100x100", iconCapable: user.photo!)!
        self.imageIdentifier = "user_\(user.id)_\(identifier)"
    }
    
    private func setDefaults() {
        name = "loading..."
    }
}