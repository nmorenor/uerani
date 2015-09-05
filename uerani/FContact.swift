//
//  FContact.swift
//  uerani
//
//  Created by nacho on 8/28/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Contact : class {
    
    var phone:String {get}
    var formattedPhone:String {get}
    var email:String {get}
}

public class FContact : Object, Contact {
    
    public dynamic var phone = ""
    public dynamic var formattedPhone = ""
    public dynamic var email = ""
    
}
