//
//  main.swift
//  OS_Test_Product
//
//  Created by 黄穆斌 on 16/8/20.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
//

import Foundation

// MARK: - Explorer Cache

class ExplorerCache {
    
    // MARK: Cache
    
    class Cache {
        var prev: Cache?
        var next: Cache?
        var key: String
        var value: AnyObject
        var size: Int = 0
        init(key: String, value: AnyObject, size: Int = 0) {
            self.key = key
            self.value = value
            self.size = size
            prev = nil
            next = nil
        }
        deinit {
            print("\(key) - \(value) - \(size) is deinit.")
        }
    }
    
    // MARK: Propertys
    
    /// LRU Queue
    var queue = [String: Cache]()
    /// The queue's max count.
    var maxCount = 10
    /// The queue's max size, the unit is byte, divide 1000000 is MB.
    var maxSize = 10000000
    
    var first: Cache?
    var last: Cache?
    var size: Int = 0
    
    // MARK: Methods

    /// Traverse all cache and print it in order.
    func traverse() {
        var cache = first
        while cache != nil {
            print(cache?.value)
            cache = cache?.next
        }
    }
    
    /// Append cache to cache queue first, if cache already has, then move it to first. And wipe overflow.
    func append(key: String, value: AnyObject, size: Int = 0) {
        if let cache = queue[key] {
            cache.value = value
            cache.size = size
            if cache !== first {
                if cache === last {
                    last = last?.prev
                }
                cache.prev?.next = cache.next
                cache.next?.prev = cache.prev
                
                cache.next = first
                first?.prev = cache
                first = cache
                
                first?.prev = nil
                last?.next = nil
            }
        } else {
            let cache = Cache(key: key, value: value, size: size)
            queue[key] = cache
            
            cache.next = first
            first?.prev = cache
            first = cache
            
            if last == nil {
                last = cache
            }
            
            self.size += size
        }
        wipeOverflow()
    }
    
    /// Remove the cache in queue.
    func remove(key: String) {
        if let cache = queue[key] {
            cache.prev?.next = cache.next
            cache.next?.prev = cache.prev
            
            if cache === first {
                first = first?.next
                first?.prev = nil
            }
            if cache === last {
                last = last?.prev
                last?.next = nil
            }
            
            self.size -= cache.size
            queue.removeValueForKey(key)
        }
    }
    
    /// Read the cache value and move it to first.
    func read(key: String) -> AnyObject? {
        if let cache = queue[key] {
            if cache !== first {
                if cache === last {
                    last = last?.prev
                }
                cache.prev?.next = cache.next
                cache.next?.prev = cache.prev
                
                cache.next = first
                first?.prev = cache
                first = cache
                
                first?.prev = nil
                last?.next = nil
            }
            return cache.value
        }
        return nil
    }
    
    /// If the total size is bigger then maxSize, or the cache numbers is bigger them maxCount, wipe the last cache.
    func wipeOverflow() {
        while self.size > maxSize || queue.count > maxCount {
            queue.removeValueForKey(last!.key)
            
            last = last?.prev
            last?.next = nil
            
            self.size -= last!.size
        }
    }
    
    /// Clear all cache.
    func clearCache() {
        for cache in queue.values {
            cache.prev = nil
            cache.next = nil
        }
        queue.removeAll(keepCapacity: true)
        first = nil
        last = nil
    }
}



let cache = ExplorerCache()
for i in 0 ..< 20 {
    cache.append("\(i)", value: "V \(i)", size: 3000000)
}

cache.traverse()


print("Done")