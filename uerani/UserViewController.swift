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

let UERANI_LOGOUT = "logout"

class UserViewController : UIViewController, UserRefreshDelegate {
    
    @IBOutlet weak var logoutButton: BorderedButton! {
        didSet {
            self.logoutButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.logoutButton.layer.borderWidth = 1.5
            self.logoutButton.highlightedBackingColor = UIColor.ueraniBlackJetColor()
            self.logoutButton.backingColor = UIColor.blackColor()
            self.logoutButton.backgroundColor = UIColor.blackColor()
        }
    }
    private var userViewTop:UserViewTop!
    private var userPhotoView:UserPhotoView!
    private var userViewModel:UserViewModel!
    @IBOutlet weak var uberSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ueraniYellowColor()
        let viewFrame = self.view.frame
        let userViewFrame = CGRectMake(0, 0, viewFrame.size.width, CGFloat(viewFrame.size.height * 0.35))
        self.userViewTop = UserViewTop(frame: userViewFrame)
        self.view.addSubview(self.userViewTop)
        
        self.userViewModel = UserViewModel(context: self.sharedContext)
        
        self.userPhotoView = UserPhotoView(frame: CGRectMake((self.userViewTop.frame.size.width/2 - 50), self.userViewTop.frame.size.height - 100, self.userViewModel.width, 100))
        self.userPhotoView.image = self.userViewModel.image
        self.userPhotoView.name = "\(self.userViewModel.name)"
        self.view.addSubview(self.userPhotoView!)
        
        UserRefreshOperation(delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let token = UberClient.sharedInstance().accessToken {
            self.uberSwitch.setOn(true, animated: false)
        } else {
            self.uberSwitch.setOn(false, animated: false)
        }
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
            self.userViewModel.loadUserData(user, context: self.sharedContext)
            
            self.userPhotoView.frame.size.width = self.userViewModel.width
            self.userPhotoView.image = self.userViewModel.image
            self.userPhotoView.name = self.userViewModel.name
            self.userPhotoView.layoutIfNeeded()
        }
    }
    
    @IBAction func uberStatusChanged(sender: UISwitch) {
        if sender.on {
            UberClient.sharedInstance().handleWebLogin()
        } else {
            UberClient.sharedInstance().setInMemoryToken(nil)
        }
    }
    
    func refreshUserDataError(errorString:String) {
        
    }
    
    @IBAction func doLogout(sender: BorderedButton) {
        //clean map
        let logoutNotification = NSNotification(name: UERANI_LOGOUT, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(logoutNotification)
        FoursquareClient.sharedInstance().userId = nil
        FoursquareClient.sharedInstance().accessToken = nil
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    
}
