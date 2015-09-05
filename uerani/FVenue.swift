//
//  FVenue.swift
//  uerani
//
//  Created by nacho on 6/13/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Venue : class {
    
    var id:String {get}
    var name:String {get}
    var completeVenue:Bool {get}
    var verified:Bool {get}
    var rating:Float {get}
    
    var c_contact:Contact? {get}
    var c_categories:GeneratorOf<Category> {get}
    var c_tags:GeneratorOf<Tag> {get}
    var c_photos:GeneratorOf<Photo> {get}
    var c_bestPhoto:Photo? {get}
    var c_price:Price? {get}
    var c_hours:Hours? {get}
    var c_location:Location? {get}
}

public class FVenue: Object, Venue {
    
    public dynamic var id = ""
    public dynamic var name = ""
    public dynamic var completeVenue = false
    public dynamic var location:FLocation?
    public dynamic var contact:FContact?
    public dynamic var categories = List<FCategory>()
    public dynamic var verified = false
    public dynamic var url = ""
    public dynamic var tags = List<FTag>()
    public dynamic var photos = List<FPhoto>()
    public dynamic var bestPhoto:FPhoto?
    public dynamic var rating:Float = 0.0
    public dynamic var price:FPrice?
    public dynamic var hours:FHours?
    
    public var c_contact:Contact? {
        return self.contact
    }
    
    public var c_bestPhoto:Photo? {
        return self.bestPhoto
    }
    
    public var c_price:Price? {
        return self.price
    }
    
    public var c_hours:Hours? {
        get {
            return self.hours
        }
    }
    
    public var c_location:Location? {
        get {
            return self.location
        }
    }
    
    public var c_categories:GeneratorOf<Category> {
        get {
            var queue = Queue<Category>()
            for next in self.categories {
                queue.enqueue(next)
            }
            return GeneratorOf<Category>(queue.generate())
        }
    }
    
    public var c_tags:GeneratorOf<Tag> {
        get {
            var queue = Queue<Tag>()
            for next in self.tags {
                queue.enqueue(next)
            }
            return GeneratorOf<Tag>(queue.generate())
        }
    }
    
    public var c_photos:GeneratorOf<Photo> {
        get {
            var queue = Queue<Photo>()
            for next in self.photos {
                queue.enqueue(next)
            }
            return GeneratorOf<Photo>(queue.generate())
        }
    }
    
    public static override func primaryKey() -> String? {
        return "id"
    }
}
