//
//  FCategory.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FCategory: Object {
    
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var pluralName = ""
    public dynamic var shortName = ""
    public dynamic var icon = FIcon()
    public dynamic var primary = false
    public dynamic var topCategory = false
    public dynamic var categories = List<FSubCategory>()
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}

public class FSubCategory:FCategory {
    
}
