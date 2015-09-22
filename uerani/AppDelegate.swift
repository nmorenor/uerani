//
//  AppDelegate.swift
//  uerani
//
//  Created by nacho on 7/18/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if url.host == "uberuerani" {
            OAuth2Swift.handleOpenURL(url)
        } else if url.host == "uerani" {
            FoursquareClient.sharedInstance().handleURL(url)
        }
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FoursquareClient.sharedInstance().config.updateIfDaysSinceUpdateExceeds(7)
        
        //if we are already logged in, go to the map view
        if let accessToken = FoursquareClient.sharedInstance().accessToken {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabView = storyboard.instantiateViewControllerWithIdentifier("MainTabBar") as? UIViewController
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            self.window!.rootViewController = tabView
            self.window!.backgroundColor = UIColor.whiteColor()
            self.window!.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
