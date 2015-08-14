//
//  BasicMapAnnotationView.swift
//  uerani
//
//  Created by nacho on 7/31/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import MapKit

class BasicMapAnnotationView : MKAnnotationView {
    
    var preventSelectionChange:Bool = false
    
    override func setSelected(selected: Bool, animated: Bool) {
        if !self.preventSelectionChange {
            super.setSelected(selected, animated: animated)
        }
    }
}
