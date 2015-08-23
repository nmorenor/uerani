//
//  UeraniTabBarViewController.swift
//  uerani
//
//  Created by nacho on 8/23/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

class UeraniTabBarViewController : UITabBarController {
    
    //yellow color
    let selectedColor = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    let unselectedColor = UIColor.whiteColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = selectedColor
        
        var mapItem = self.tabBar.items![0] as! UITabBarItem
        var mapImage = UIImage(named: "map")
        mapItem.image = mapImage!.imageWithColor(unselectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        mapItem.selectedImage = mapImage!.imageWithColor(selectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        var listItem = self.tabBar.items![1] as! UITabBarItem
        var listImage = UIImage(named: "list")
        listItem.image = listImage!.imageWithColor(unselectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        listItem.selectedImage = listImage!.imageWithColor(selectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        var userItem = self.tabBar.items![2] as! UITabBarItem
        var userImage = UIImage(named: "user")
        userItem.image = userImage!.imageWithColor(unselectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        userItem.selectedImage = userImage!.imageWithColor(selectedColor)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
    }
}