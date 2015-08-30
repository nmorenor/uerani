//
//  UserViewController.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class UserViewController : UIViewController {
    
    private var userViewTop:UserViewTop!
    let yellowColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = yellowColor
        let viewFrame = self.view.frame
        let userViewFrame = CGRectMake(0, 0, viewFrame.size.width, CGFloat(viewFrame.size.height * 0.35))
        self.userViewTop = UserViewTop(frame: userViewFrame)
        self.view.addSubview(self.userViewTop)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
