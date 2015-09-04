//
//  IconCapable.swift
//  uerani
//
//  Created by nacho on 9/3/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol IconCapable : class {
    
    var iconPrefix:String {get}
    var iconSuffix:String {get}
}
