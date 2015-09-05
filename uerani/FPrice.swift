//
//  FPrice.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Price : class {
    
    var tier:Int {get}
    var message:String {get}
}

public class FPrice:Object, Price {
    
    public dynamic var tier:Int = 1
    public dynamic var message:String = ""
}