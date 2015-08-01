//
//  SearchBoxCenter.swift
//  uerani
//
//  Created by nacho on 7/15/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit

import RealmSwift

public class SearchBoxCenter: Object {
   
    public dynamic var id:String = NSUUID().UUIDString
    public dynamic var lat:Double = 0.0
    public dynamic var lng:Double = 0.0
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}
