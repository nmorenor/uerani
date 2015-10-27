//
//  IconCapable.swift
//  uerani
//
//  Created by nacho on 9/3/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol IconCapable : class {
    
    var iprefix:String {get}
    var isuffix:String {get}
}

func getImageIdentifier<T:IconCapable>(size:String, iconCapable:T) -> String? {
    if let url = NSURL(string: "\(iconCapable.iprefix)\(size)\(iconCapable.isuffix)") {
        return getImageIdentifier(url)
    }
    return nil
}

func getImageIdentifier(size:String, iconCapable:IconCapable) -> String? {
    if let url = NSURL(string: "\(iconCapable.iprefix)\(size)\(iconCapable.isuffix)") {
        return getImageIdentifier(url)
    }
    return nil
}

func getImageIdentifier(url:NSURL) -> String? {
    if let name = url.lastPathComponent, let pathComponents = url.pathComponents {
        let prefix_image_name = pathComponents[pathComponents.count - 2] 
        return "\(prefix_image_name)_\(name)"
    }
    return nil
}