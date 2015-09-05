//
//  FHours.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FHours: Object {
    
    public dynamic var status:String = ""
    public dynamic var isOpen:Bool = false
    public dynamic var timeframes = List<FTimeFrames>()
}