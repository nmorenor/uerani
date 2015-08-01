//
//  FContact.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FContact: Object {
    public dynamic var phone = ""
    
    public override static func primaryKey() -> String? {
        return "phone"
    }
}