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
    
    let blackJetColor:UIColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    let yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    
    @IBOutlet weak var connectButton: FSButton! {
        didSet {
            connectButton.borderColor = yellowColor
            connectButton.backingColor = UIColor.blackColor()
            connectButton.highlightedBackingColor = blackJetColor
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
