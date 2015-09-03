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
        let statusCode:FSOAuthStatusCode = FSOAuth.authorizeUserUsingClientId(FoursquareClient.Constants.FOURSQUARE_CLIENT_ID, callbackURIString: FoursquareClient.Constants.FOURSQUARE_CALLBACK_URI);
        
        
        switch (statusCode) {
        case FSOAuthStatusCode.Success:
            //there is native auth mechanism
            FoursquareClient.sharedInstance().foursquareNativeAuthentication = true
            break;
        case FSOAuthStatusCode.ErrorInvalidCallback:
            println("Invalid callback URI")
            break;
            
        case FSOAuthStatusCode.ErrorFoursquareNotInstalled:
            FoursquareClient.sharedInstance().handleWebLogin()
            break;
            
        case FSOAuthStatusCode.ErrorInvalidClientID:
            println("Error Invalid client ID")
            break;
        case FSOAuthStatusCode.ErrorFoursquareOAuthNotSupported:
            println("OAuth is not supported")
            break;
            
        default:
            
            break;
            
        }
        
    }
    
    func successLogin() {
        self.performSegueWithIdentifier("showMainSegue", sender: self)
    }
    
    func errorLogin(errorMessage:String?) {
        println(errorMessage)
    }
}
