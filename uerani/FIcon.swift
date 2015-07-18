//
//  FIcon.swift
//  grabbed
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public class FIcon: Object {
    
    public struct Sizes {
        static let S32 = "32"
        static let S44 = "44"
        static let S64 = "64"
        static let S88 = "88"
    }
    
    public dynamic var prefix = ""
    public dynamic var suffix = ""
}