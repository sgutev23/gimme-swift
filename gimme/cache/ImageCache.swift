//
//  ImageCache.swift
//  gimme
//
//  Created by Daniel Mihai on 17/02/2018.
//  Copyright © 2018 lepookey. All rights reserved.
//

import Foundation
import UIKit

//LRU cache
final class ImageCache {
    private let MAX_SIZE = 50
    private var cache: [String: UIImage] = [:]
    private var priority: LinkedList<String> = LinkedList<String>()
    private var key2node: [String: LinkedList<String>.LinkedListNode<String>] = [:]
    
    static let shared = ImageCache()
    
    private init() {
        
    }
    
    public func get(_ key: String) -> UIImage? {
        guard let cachedImage = cache[key] else {
            return nil
        }
        
        remove(key)
        insert(key, value: cachedImage)
        
        return cachedImage
    }
    
    public func set(_ key: String, value: UIImage) {
        if cache[key] != nil {
            remove(key)
        } else if priority.size >= MAX_SIZE, let keyToRemove = priority.last?.value {
            remove(keyToRemove)
        }
        
        insert(key, value: value)
    }
    
    private func remove(_ key: String) {
        cache.removeValue(forKey: key)
        
        guard let node = key2node[key] else {
            return
        }
        
        priority.remove(node: node)
        key2node.removeValue(forKey: key)
    }
    
    private func insert(_ key: String, value: UIImage) {
        cache[key] = value
        
        priority.insert(key, atIndex: 0)
        
        guard let first = priority.first else {
            return
        }
        
        key2node[key] = first
    }
    
    
    
}
