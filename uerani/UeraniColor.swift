//
//  UeraniColor.swift
//  uerani
//
//  Created by nacho on 9/3/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    private static let ueraniYellow = UIColor(red: 255.0/255.0, green: 217.0/255.0, blue: 8/255.0, alpha: 1.0)
    private static let blackJetColor:UIColor = UIColor(red: 52.0/255.0, green: 52.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private static let ueraniDarkYellow = UIColor(red: 231.0/255.0, green: 182.0/255.0, blue: 0/255.0, alpha: 1.0)
    
    static func ueraniYellowColor() -> UIColor {
        return ueraniYellow
    }
    
    static func ueraniDarkYellowColor() -> UIColor {
        return ueraniDarkYellow
    }
    
    static func ueraniBlackJetColor() -> UIColor {
        return blackJetColor
    }
}