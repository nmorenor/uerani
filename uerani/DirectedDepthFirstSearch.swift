//
//  DirectedDepthFirstSearch.swift
//  uerani
//
//  Created by nacho on 8/26/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class DirectedDepthFirstSearch {
    
    private var marked:[Bool]
    private var count:Int
    
    init(g:DirectedGraph, s:Int) {
        self.marked = Array<Bool>(count: g.v, repeatedValue: false)
        self.count = 0
        self.dfs(g, v: s)
    }
    
    private func dfs(g:DirectedGraph, v:Int) {
        self.marked[v] = true
        for w in g.adj[v] {
            if !self.marked[w] {
                self.marked[w] = true
                self.count += 1
            }
        }
    }
    
    public func marked(v:Int) -> Bool {
        return self.marked[v]
    }
}