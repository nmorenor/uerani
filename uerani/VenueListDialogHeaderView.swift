//
//  VenueListDialogHeaderView.swift
//  uerani
//
//  Created by nacho on 9/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

public class VenueListDialogHeaderView : UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 14.0)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        return label
        }()
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.layer.cornerRadius = 6.0
    }
    
    public override func didMoveToSuperview() {
        self.addSubview(label)
    }
    
    public override func layoutSubviews() {
        label.frame = CGRect(x: 0.0, y: 0.0, width: bounds.size.width, height: bounds.size.height)
    }
}
