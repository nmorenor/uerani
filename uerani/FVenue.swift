//
//  FVenue.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FVenue: Object {
    
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var completeVenue = false
    public dynamic var location:FLocation?
    public dynamic var cotact:FContact?
    public dynamic var categories = List<FCategory>()
    public dynamic var verified = false
    public dynamic var url = ""
    public dynamic var tags = List<FTag>()
    public dynamic var photos = List<FPhoto>()
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}
