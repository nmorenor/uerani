//
//  FCategory.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Category : class {
    
    var id:String {get}
    var name:String {get}
    var pluralName:String {get}
    var shortName:String {get}
    var primary: Bool {get}
    var topCategory: Bool {get}
    
    var c_categories:GeneratorOf<Category> {get}
    
}

public class FCategory: Object, IconCapable, Category {
    
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var pluralName = ""
    public dynamic var shortName = ""
    public dynamic var icon:FIcon?
    public dynamic var primary = false
    public dynamic var topCategory = false
    public dynamic var categories = List<FSubCategory>()
    
    public var iprefix:String {
        get {
            return self.icon!.prefix
        }
    }
    public var isuffix:String {
        get {
            return self.icon!.suffix
        }
    }
    
    public var c_categories:GeneratorOf<Category> {
        get {
            var queue = Queue<Category>()
            for next in categories {
                queue.enqueue(next)
            }
            return GeneratorOf<Category>(queue.generate())
        }
    }
    
    public static override func primaryKey() -> String? {
        return "id"
    }
    
    func getCategoryIds(categories:List<FSubCategory>) ->[String] {
        var result = [String]()
        for child in categories {
            result.append(child.id)
            if child.categories.count > 0 {
                result += getCategoryIds(child.categories)
            }
        }
        return result
    }
}

public class FSubCategory:FCategory, Category {
    
}
