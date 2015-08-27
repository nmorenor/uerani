//
//  DirectedGraph.swift
//  uerani
//
//  Created by nacho on 8/26/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class DirectedGraph {
    
    var v:Int
    var e:Int
    var adj:Array<Array<Int>>
    
    init(vSize:Int) {
        self.v = vSize
        self.e = 0
        self.adj = Array<Array<Int>>(count: self.v, repeatedValue: [Int]())
    }
    
    convenience init(G:DirectedGraph) {
        self.init(vSize: G.v)
        self.e = G.e
        
        for v in 0..<G.v {
            var reverse:[Int] = [Int]()
            for w in G.adj[v] {
                reverse.append(w)
            }
            for w in reverse {
                self.adj[v].append(w)
            }
        }
    }
    
    public func addEdge(v:Int, w:Int) {
        if (v < 0 || v >= self.v) {
            return
        }
        if (w < 0 || w >= self.v) {
            return
        }
        self.e += 1
        self.adj[v].append(w)
    }
}
