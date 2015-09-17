//
//  AddVenueToListController.swift
//  uerani
//
//  Created by nacho on 9/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class AddVenueToListController : UIViewController {
    
    var containerView:UIView!
    var rootViewController:UIViewController!
    
    var isAlertOpen:Bool = false
    var closeAction:(()->Void)?
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    var tapRecognizer: UITapGestureRecognizer!
    var dialogView:VenueListsDialogView!
    
    public class DialogViewResponder {
        
        let dialogView:AddVenueToListController
        
        init(dialogView:AddVenueToListController) {
            self.dialogView = dialogView
        }
        
        public func close() {
            self.dialogView.closeView(false)
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    public init() {
        super.init(nibName:nil, bundle:nil)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer.numberOfTapsRequired = 1
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.rootViewController.view.addGestureRecognizer(self.tapRecognizer)
        
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.rootViewController.view.removeGestureRecognizer(self.tapRecognizer)
    }
    
    public func addCloseAction(action: ()->Void) {
        self.closeAction = action
    }
    
    public func show(viewController: UIViewController) -> DialogViewResponder {
        self.rootViewController = viewController
        self.rootViewController.addChildViewController(self)
        
        self.rootViewController.view.addSubview(view)
        
        let size = UIScreen.mainScreen().bounds.size
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        self.containerView = UIView()
        self.containerView.layer.shadowOffset = CGSizeMake(3, 3)
        self.containerView.layer.shadowOpacity = 0.8
        self.containerView.layer.shadowRadius = 2
        self.containerView.layer.cornerRadius = 2
        self.view.addSubview(self.containerView!)
        
        self.view.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame = self.view.frame
        
        let dialogHieght:CGFloat = self.view.frame.size.height * 0.5
        self.dialogView = VenueListsDialogView(frame: CGRectMake(25, (self.view.frame.size.height/6) - 35, self.view.frame.size.width - 50, dialogHieght))
        self.dialogView.closeAction = self.closeView
        self.containerView.addSubview(self.dialogView)
        
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: nil, animations: {
            self.containerView.center = self.rootViewController.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return DialogViewResponder(dialogView: self)
    }
    
    public func closeView(withCallback:Bool) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self.containerView.center.y = -(self.viewHeight! + 10)
            }, completion: { finished in
                UIView.animateWithDuration(0.1, animations: {
                    self.view.alpha = 0
                    }, completion: { finished in
                        if withCallback == true {
                            if let action = self.closeAction {
                                action()
                            }
                        }
                        self.removeView()
                })
                
        })
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.closeView(true)
    }
    
    func removeView() {
        isAlertOpen = false
        self.view.removeFromSuperview()
    }
}