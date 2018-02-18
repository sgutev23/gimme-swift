//
//  LinkedList.swift
//  gimme
//
//  Created by Daniel Mihai on 17/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import Foundation

public final class LinkedList<T> {
    public class LinkedListNode<T> {
        var value: T
        var next: LinkedListNode?
        weak var previous: LinkedListNode?
        
        public init(value: T){
            self.value = value
        }
    }
    
    public typealias Node = LinkedListNode<T>
    
    fileprivate var head: Node?
    
    public init() {
        
    }
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    
    public var last: Node? {
        if var node = head {
            while let next = node.next {
                node = next
            }
            
            return node
        }
        
        return nil
    }
    
    public var size: Int {
        if var node = head {
            var count = 1
            while let next = node.next {
                node = next
                count += 1
            }
            
            return count
        }
        
        return 0
    }
    
    public func node(atIndex index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            
            while node != nil {
                if i == 0 {
                    return node
                }
                
                i -= 1
                node = node!.next
            }
        }
        
        return nil
    }
    
    public subscript(index: Int) -> T {
        let node = self.node(atIndex: index)
        
        assert(node != nil)
        
        return node!.value
    }
    
    public func append(_ value: T) {
        let newNode = Node(value: value)
        
        self.append(newNode)
    }
    
    public func append(_ node: Node) {
        let newNode = LinkedListNode(value: node.value)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    
    public func append(_ list: LinkedList) {
        var nodeToCopy = list.head
        
        while let node = nodeToCopy {
            self.append(node.value)
            nodeToCopy = node.next
        }
    }
    
    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        assert(index >= 0)
        
        var i = index
        var next = head
        var previous: Node?
        
        while next != nil && i > 0 {
            i -= 1
            previous = next
            next = next!.next
        }
        
        assert(i == 0)
        
        return (previous, next)
    }
    
    public func insert(_ value: T, atIndex index: Int) {
        let newNode = Node(value: value)
        
        self.insert(newNode, atIndex: index)
    }
    
    public func insert(_ node: Node, atIndex index: Int) {
        let (previous, next) = nodesBeforeAndAfter(index: index)
        let newNode = LinkedListNode(value: node.value)
        
        newNode.previous = previous
        newNode.next = next
        previous?.next = newNode
        next?.previous = newNode
        
        if previous == nil {
            head = newNode
        }
    }
    
    public func insert(_ list: LinkedList, atIndex index: Int) {
        if list.isEmpty {
            return
        }

        let (previous, next) = nodesBeforeAndAfter(index: index)
        var nodeToCopy = list.head
        var newNode: Node?
        
        while let node = nodeToCopy {
            newNode = Node(value: node.value)
            newNode?.previous = previous
            
            if let previous = previous {
                previous.next = newNode
            } else {
                self.head = newNode
            }
            nodeToCopy = nodeToCopy?.next
            
        }
        
        previous?.next = next
        next?.previous = previous
    }
    
    public func removeAll() {
        head = nil
    }
    
    @discardableResult public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        
        return node.value
    }
    
    @discardableResult public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }
    
    @discardableResult public func remove(atIndex index: Int) -> T {
        let node = self.node(atIndex: index)
        
        assert(node != nil)
        
        return remove(node: node!)
    }
}
