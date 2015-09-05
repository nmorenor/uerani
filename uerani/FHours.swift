//
//  FHours.swift
//  uerani
//
//  Created by nacho on 9/5/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Hours : class {
    
    var status:String {get}
    var isOpen:Bool {get}
    
    var c_timeFrames:GeneratorOf<TimeFrames> {get}
}

public class FHours: Object, Hours {
    
    public dynamic var status:String = ""
    public dynamic var isOpen:Bool = false
    public dynamic var timeframes = List<FTimeFrames>()
    
    public var c_timeFrames:GeneratorOf<TimeFrames> {
        get {
            var queue = Queue<TimeFrames>()
            for next in self.timeframes {
                queue.enqueue(next)
            }
            return GeneratorOf<TimeFrames>(queue.generate())
        }
    }
}