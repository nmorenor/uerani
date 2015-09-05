//
//  FPhoto.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Photo : IconCapable {
    
    var id:String {get}
    var suffix:String {get}
    var prefix:String {get}
    var visibility:String {get}
}

public class FPhoto: Object, IconCapable, Photo {
    
    public dynamic var id = ""
    public dynamic var createdAt = 0
    public dynamic var prefix = ""
    public dynamic var suffix = ""
    public dynamic var visibility = ""
    
    public var iprefix:String {
        get {
            return self.prefix
        }
    }
    public var isuffix:String {
        get {
            return self.suffix
        }
    }
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}
