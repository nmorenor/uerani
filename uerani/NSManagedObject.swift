//
//  NSManagedObject.swift
//  Virtual Tourist
//
//  Created by nacho on 6/8/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    class func entityName() -> String {
        let fullClassName = NSStringFromClass(object_getClass(self))
        let nameComponents = fullClassName.characters.split{ $0 == "."}.map { String($0) }
        return nameComponents.last!
    }
    
    convenience init(context:NSManagedObjectContext) {
        let name = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
