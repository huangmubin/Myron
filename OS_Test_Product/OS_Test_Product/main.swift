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
        var value: AnyObject
        var size: Int = 0
        init(value: AnyObject, size: Int = 0) {
            self.value = value
            self.size = size
            prev = nil
            next = nil
        }
    }
    
    // MARK: Propertys
    
    /// LRU 队列
    var queue = [String: Cache]()
    /// 最大数量
    var maxCount = 10
    /// 最大内存
    var maxSize = 100000
    
    var first: Cache?
    var last: Cache?
    
    // MARK: Methods

    /// 遍历所有
    func traverse() {
        var cache = first
        while cache != nil {
            print(cache?.value)
            cache = cache?.next
        }
    }
    
    /// 添加缓存
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
            let cache = Cache(value: value, size: size)
            queue[key] = cache
            
            cache.next = first
            first?.prev = cache
            first = cache
            
            if last == nil {
                last = cache
            }
        }
    }
    
    /// 删除缓存
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
            
            queue.removeValueForKey(key)
        }
    }
    
    /// 读取缓存
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
}

let cache = ExplorerCache()

for i in 0 ..< 5 {
    cache.append("\(i)", value: i, size: 10)
}

for i in 0 ..< 5 {
    cache.append("\(4 - i)", value: "\(4-i) ++", size: 10)
}

cache.traverse()

print("=============")

//for i in 0 ..< 5 {
//    //cache.append("\(i)", value: i, size: 10)
//    cache.remove("\(i)")
//}
////cache.remove("4")

cache.read("3")

cache.traverse()




print("Done")