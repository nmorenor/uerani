//
//  FTag.swift
//  grabbed
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class FTag:Object {
    
    public dynamic var tagvalue = ""
    
    public class override func indexedProperties() -> [String] {
        return ["tagvalue"]
    }
    
}
