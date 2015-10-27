//
//  WebViewController.swift
//  uerani
//
//  Created by nacho on 10/27/15.
//  Copyright © 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

class WebViewController: OAuthWebViewController {
    var targetURL : NSURL?
    var webView : UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        webView.frame = CGRectMake(0, 20, self.view.bounds.width, self.view.bounds.height)
        webView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleHeight]
        webView.scalesPageToFit = true
        view.addSubview(webView)
        loadAddressURL()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func handle(url: NSURL) {
        self.targetURL = url
        super.handle(url)
    }
    
    func loadAddressURL() {
        if let targetURL = targetURL {
            let req = NSURLRequest(URL: targetURL)
            webView.loadRequest(req)
        }
    }
}