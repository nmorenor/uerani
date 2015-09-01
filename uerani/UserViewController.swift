//
//  UserViewController.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserViewController : UIViewController, UserRefreshDelegate {
    
    private var userViewTop:UserViewTop!
    private var userPhotoView:UserPhotoView?
    
    let yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = yellowColor
        let viewFrame = self.view.frame
        let userViewFrame = CGRectMake(0, 0, viewFrame.size.width, CGFloat(viewFrame.size.height * 0.35))
        self.userViewTop = UserViewTop(frame: userViewFrame)
        self.view.addSubview(self.userViewTop)
        UserRefreshOperation(delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: Core Data
    
    var sharedContext:NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().dataStack.managedObjectContext
    }
    
    func refreshUserData(user:CDUser) {
        dispatch_async(dispatch_get_main_queue()) {
            var user = self.sharedContext.objectWithID(user.objectID) as! CDUser
            var userName = "\(user.firstName) \(user.lastName)"
            if self.userPhotoView == nil {
                let fontSize:CGFloat = 14.0
                var font = UIFont(name: "HelveticaNeue", size: fontSize)!
                var attributedString = NSAttributedString(string:userName, attributes: [NSFontAttributeName : font])
                let asize:CGSize = attributedString.size()
                
                self.userPhotoView = UserPhotoView(frame: CGRectMake((self.userViewTop.frame.size.width/2 - 50), self.userViewTop.frame.size.height - 100, (asize.width > 100 ? asize.width : 100), 100))
                
                var photoURL = "\(user.photo!.prefix)100x100\(user.photo!.suffix)"
                let url = NSURL(string: photoURL)!
                var imageCacheName = "user_\(user.id)_\(url.lastPathComponent!)"
                
                self.userPhotoView?.image = ImageCache.sharedInstance().imageWithIdentifier(imageCacheName)
                self.userPhotoView?.name = userName
                self.view.addSubview(self.userPhotoView!)
            }
        }
    }
    
    func refreshUserDataError(errorString:String) {
        //TODO:
    }
}
