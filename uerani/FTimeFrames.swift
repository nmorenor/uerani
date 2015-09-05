//
//  FTimeFrames.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FTimeFrames : Object {
    
    public dynamic var days:String = ""
    public dynamic var open = List<FTimeOpenFrames>()
    
}

public class FTimeOpenFrames: Object {
    
    public dynamic var renderedTime:String = ""
}
