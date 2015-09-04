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

func getCategoryImageIdentifier<T:IconCapable>(size:String, category:T) -> String? {
    if let url = NSURL(string: "\(category.iconPrefix)\(size)\(category.iconSuffix)") {
        return getImageIdentifier(url)
    }
    return nil
}

func getImageIdentifier(url:NSURL) -> String? {
    if let name = url.lastPathComponent, let pathComponents = url.pathComponents {
        let prefix_image_name = pathComponents[pathComponents.count - 2] as! String
        return "\(prefix_image_name)_\(name)"
    }
    return nil
}