//
//  LoginViewController.swift
//  uerani
//
//  Created by nacho on 8/17/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import FSOAuth

protocol AccessTokenLoginDelegate : class {
    
    func successLogin()
    
    func errorLogin(errorMessage:String?)
}

protocol WebTokenDelegate : class {
    
    func handleWebLogin()
}

class LoginViewController: UIViewController, AccessTokenLoginDelegate {
    
    @IBOutlet weak var connectButton: FSButton! {
        didSet {
            connectButton.borderColor = UIColor.ueraniYellowColor()
            connectButton.backingColor = UIColor.blackColor()
            connectButton.highlightedBackingColor = UIColor.ueraniBlackJetColor()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FoursquareClient.sharedInstance().accessTokenLoginDelegate = self
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
    
    @IBAction func connectToFoursquare(sender: FSButton) {
        let statusCode:FSOAuthStatusCode = FSOAuth.authorizeUserUsingClientId(FoursquareClient.Constants.FOURSQUARE_CLIENT_ID, nativeURICallbackString: FoursquareClient.Constants.FOURSQUARE_CALLBACK_URI, universalURICallbackString: nil, allowShowingAppStore:false);
        
        
        switch (statusCode) {
        case FSOAuthStatusCode.Success:
            //there is native auth mechanism
            FoursquareClient.sharedInstance().foursquareNativeAuthentication = true
            break;
        case FSOAuthStatusCode.ErrorInvalidCallback:
            Swift.print("Invalid callback URI", terminator: "")
            break;
            
        case FSOAuthStatusCode.ErrorFoursquareNotInstalled:
            FoursquareClient.sharedInstance().handleWebLogin()
            break;
            
        case FSOAuthStatusCode.ErrorInvalidClientID:
            Swift.print("Error Invalid client ID", terminator: "")
            break;
        case FSOAuthStatusCode.ErrorFoursquareOAuthNotSupported:
            Swift.print("OAuth is not supported", terminator: "")
            break;
            
        }
        
    }
    
    func successLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabView = storyboard.instantiateViewControllerWithIdentifier("UeraniTabBarViewController")
        self.presentViewController(tabView, animated: true, completion: nil)
        //self.performSegueWithIdentifier("showMainSegue", sender: self)
    }
    
    func errorLogin(errorMessage:String?) {
        Swift.print(errorMessage, terminator: "")
    }
}
