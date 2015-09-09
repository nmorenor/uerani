//
//  CategroyVenueFilter.swift
//  uerani
//
//  Created by nacho on 8/26/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation
import CoreData
import RealmSwift

public class CategroyVenueFilter {
    
    private var filter:DirectedDepthFirstSearch!
    private var symbolGraph:SymbolGraph<CategoryFilter>!
    private var catFilter:CategoryFilter
    
    init(filter:CategoryFilter) {
        self.catFilter = CategoryFilter(id: filter.id)
        let realm = Realm(path: FoursquareClient.sharedInstance().foursquareDataCacheRealmFile.path!)
        let results = realm.objects(FCategory)
        
        var filterGraph:[CategoryFilter] = [CategoryFilter]()
        for next in results {
            var nextFilter = CategoryFilter(id: next.id)
            filterGraph.append(nextFilter)
            if next.id == filter.id {
                self.catFilter.setCategories(next)
            }
        }
        let sresults = realm.objects(FSubCategory)
        for next in sresults {
            var nextFilter = CategoryFilter(id: next.id)
            filterGraph.append(nextFilter)
            if next.id == filter.id {
                self.catFilter.setCategories(next)
            }
        }
        
        self.symbolGraph = SymbolGraph(keys: filterGraph, p:self.catFilter)
        
        var index = symbolGraph.indexOf(filter)
        if index == -1 {
            if DEBUG {
                println("can not find filter in graph")
            }
        } else {
            self.filter = DirectedDepthFirstSearch(g: symbolGraph.g, s: index)
        }
    }
    
    func filterVenues(venues:GeneratorOf<FVenue>) -> GeneratorOf<FVenue> {
        var result = Queue<FVenue>()
        outer : for next in venues {
            for nextCategory in next.categories {
                var index = self.symbolGraph.indexOf(CategoryFilter(id: nextCategory.id))
                if (index == -1) {
                    if DEBUG {
                        println("Can not find index for graph \(nextCategory.id)")
                    }
                    continue
                }
                if filter.marked(index) {
                    result.enqueue(next)
                    continue outer
                }
            }
            
        }
        return GeneratorOf<FVenue>(result.generate())
    }
}

public struct CategoryFilter: KeySymbolVertex {
    
    public var categories:[String]?
    public let id:String
    
     public var hashValue:Int {
        get {
            return id.hashValue
        }
    }
    
    init(id:String) {
        self.id = id
    }
    
    mutating func setCategories(category:FCategory) {
        self.categories = category.getCategoryIds(category.categories)
    }
    
    public func hasEdge<T:KeySymbolVertex>(key: T) -> Bool {
        if let key = key as? CategoryFilter, categories = self.categories {
            if self.id == key.id {
                return true
            }
            var searching = key.id
            for next in categories {
                if next == searching {
                    return true
                }
            }
        }
        return false
    }
}

public func ==(lhs:CategoryFilter, rhs:CategoryFilter) -> Bool {
    return lhs.id == rhs.id
}
