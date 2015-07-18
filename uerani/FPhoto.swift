//
//  FPhoto.swift
//  grabbed
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FPhoto: Object {
    
    public dynamic var id = ""
    public dynamic var createdAt = 0
    public dynamic var prefix = ""
    public dynamic var suffix = ""
    public dynamic var visibility = ""
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}
