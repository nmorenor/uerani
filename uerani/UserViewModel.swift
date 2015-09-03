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
    
    func populate(context:NSManagedObjectContext) {
        if let userId = FoursquareClient.sharedInstance().userId {
            var request = NSFetchRequest(entityName: "CDUser")
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
            request.predicate = NSPredicate(format: "id == %@", userId)
            
            var error:NSError? = nil
            var cResult = context.executeFetchRequest(request, error: &error)
            if let error = error {
                if DEBUG {
                    println("*** \(toString(UserViewModel.self)) ERROR: [\(__LINE__)] \(__FUNCTION__) Can not load user data from core data: \(error)")
                    self.setDefaults()
                }
            } else if let result = cResult where result.count > 0 {
                var user = result.first! as! CDUser
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
        var font = UIFont(name: fontName, size: fontSize)!
        var attributedString = NSAttributedString(string:name, attributes: [NSFontAttributeName : font])
        let asize:CGSize = attributedString.size()
        
        self.width  = asize.width > 100 ? asize.width : 100
        
        var photoURL = "\(user.photo!.prefix)100x100\(user.photo!.suffix)"
        let url = NSURL(string: photoURL)!
        self.imageIdentifier = "user_\(user.id)_\(url.lastPathComponent!)"
    }
    
    private func setDefaults() {
        name = "loading..."
    }
}