//
//  LoginViewController.swift
//  uerani
//
//  Created by nacho on 8/17/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func connectToFoursquare(sender: FSButton) {
        self.performSegueWithIdentifier("showMapSegue", sender: self)
    }
}
