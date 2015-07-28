//
//  CalloutAnnotation.swift
//  uerani
//
//  Created by nacho on 7/27/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import UIKit
import MapKit

class CalloutAnnotation: NSObject, MKAnnotation, Hashable, Equatable {
   
    let title:String = ""
    let subtitle:String = ""
    let coordinate:CLLocationCoordinate2D
    
    override var hashValue: Int {
        get {
            return self.calculateHashValue()
        }
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    
    private func calculateHashValue() -> Int {
        let prime:Int = 7
        var result:Int = 1
        var toHash = NSString(format: "c[%.8f,%.8f]", coordinate.latitude, coordinate.longitude)
        result = prime * result + toHash.hashValue
        return result
    }
}

func ==(lhs: CalloutAnnotation, rhs:CalloutAnnotation) -> Bool {
    return lhs.coordinate.isEqual(rhs.coordinate)
}

extension CLLocationCoordinate2D {
    
    func isEqual(rhs:CLLocationCoordinate2D) -> Bool {
        return self.latitude == rhs.latitude && self.longitude == rhs.longitude
    }
}
