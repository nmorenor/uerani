//
//  FIcon.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Icon : class {
    
    var prefix:String {get}
    var suffix:String {get}
}

public class FIcon: Object, Icon {
    
    public enum FIconSize : CustomStringConvertible {
        case S32;
        case S44;
        case S64;
        case S88;
        
        static let allValues = [S32, S44, S64, S88]
        
        public var description:String {
            switch self {
            case .S32:
                return "32"
            case .S44:
                return "44"
            case .S64:
                return "64"
            case .S88:
                return "88"
            }
        }
    }
    
    public dynamic var prefix = ""
    public dynamic var suffix = ""
}