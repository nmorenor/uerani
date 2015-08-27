//
//  SymbolGraph.swift
//  uerani
//
//  Created by nacho on 8/26/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public protocol KeySymbolVertex: Hashable {
    
    func hasEdge<T:KeySymbolVertex>(key:T) -> Bool
}

public class SymbolGraph<T:KeySymbolVertex> {
    private var st:[T:Int]
    private var keys:[T]
    public var g:DirectedGraph
    
    init(keys:[T], p:T) {
        self.st = [T:Int]()
        for i in 0..<keys.count {
            var nextKey:T = keys[i]
            if self.st[nextKey] == nil {
                self.st[nextKey] = self.st.count
            }
        }
        self.keys = keys
        
        self.g = DirectedGraph(vSize: self.st.count)
        for c in keys {
            if p.hasEdge(c) {
                g.addEdge(self.st[p]!, w: self.st[c]!)
            }
        }
        
    }
    
    public func contains(key:T) -> Bool {
        if let v = self.st[key] {
            return true
        }
        return false
    }
    
    public func indexOf(key:T) -> Int {
        if let v = self.st[key] {
            return v
        }
        return -1
    }
    
    public func get(index:Int) -> T? {
        return self.keys[index]
    }
}