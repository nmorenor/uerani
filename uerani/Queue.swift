//
//  Queue.swift
//  uerani
//
//  Not used yet but kind of cool to have
//  Created by nacho on 8/26/15.
//  Copyright (c) 2015 Ignacio Moreno. All rights reserved.
//

import Foundation

public class Queue<T> : SequenceType {
    
    private var first:QNode<T>?
    private var last:QNode<T>?
    var size:Int = 0
    
    public func enqueue(value:T) {
        let toEnqueue = QNode<T>()
        toEnqueue.item = value
        if let first = self.first, _ = first.item {
            let oldLast = self.last
            oldLast?.next = toEnqueue
            self.last = toEnqueue
        } else {
            self.first = toEnqueue
            self.last = toEnqueue
        }
        size += 1
    }
    
    public func dequeue() -> T? {
        if let first = self.first, item = first.item {
            self.first = first.next
            size -= 1
            return item
        }
        return nil
    }
    
    public func generate() -> MyGenerator<T> {
        return MyGenerator(node: self.first)
    }
}

public struct MyGenerator<T>:GeneratorType {
    
    var currentNode:QNode<T>?
    public typealias Element = T
    
    init(node:QNode<T>?) {
        self.currentNode = node
    }
    
    mutating public func next() -> Element? {
        if let currentNode = self.currentNode, nextItem = currentNode.item {
            self.currentNode = currentNode.next
            return nextItem
        }
        return nil
    }
    
}

