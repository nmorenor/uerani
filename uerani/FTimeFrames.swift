//
//  FTimeFrames.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol TimeFrames : class {
    
    var days:String {get}
    var c_open:GeneratorOf<TimeOpenFrames> {get}
}

public protocol TimeOpenFrames {
    
    var renderedTime:String {get}
}

public class FTimeFrames : Object, TimeFrames {
    
    public dynamic var days:String = ""
    public dynamic var open = List<FTimeOpenFrames>()
    
    public var c_open:GeneratorOf<TimeOpenFrames> {
        get {
            var queue = Queue<TimeOpenFrames>()
            for next in open {
                queue.enqueue(next)
            }
            return GeneratorOf<TimeOpenFrames>(queue.generate())
        }
    }
    
}

public class FTimeOpenFrames: Object, TimeOpenFrames {
    
    public dynamic var renderedTime:String = ""
}
