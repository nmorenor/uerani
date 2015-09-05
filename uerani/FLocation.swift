//
//  FLocation.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Location : class {
    
    var lat:Double {get}
    var lng:Double {get}
    var address:String {get}
    var city:String {get}
    var state:String {get}
    var postalCode:String {get}
    var country:String {get}
}

public class FLocation: Object, Location {
    
    public dynamic var lat:Double = 0.0
    public dynamic var lng:Double = 0.0
    public dynamic var address = ""
    public dynamic var city = ""
    public dynamic var state = ""
    public dynamic var postalCode = ""
    public dynamic var country = ""
}
