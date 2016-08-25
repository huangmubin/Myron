//
//  main.swift
//  OS_Test_Product
//
<<<<<<< HEAD
//  Created by 黄穆斌 on 16/8/23.
//  Copyright © 2016年 Myron. All rights reserved.
=======
//  Created by 黄穆斌 on 16/8/20.
//  Copyright © 2016年 MuBinHuang. All rights reserved.
>>>>>>> origin/master
//

import Foundation

<<<<<<< HEAD
class Rename {
    var source: String = "/Users/Myron/Downloads/Source"
    var target: String = "/Users/Myron/Downloads/Target"
    var fileType: String = ".png"
    var insert: String = "_YES_"
    var rename: Bool = false
    
    func prefix() {
        if let subpaths = NSFileManager.defaultManager().subpathsAtPath(source) {
            for subpath in subpaths {
                if subpath.hasSuffix(fileType) {
                    do {
                        try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + insert + subpath)
                        if rename {
                            try NSFileManager.defaultManager().removeItemAtPath(source + "/" + subpath)
                        }
                    } catch {
                        print("\(subpath) is copy Error.")
                    }
                }
            }
        }
    }
    
    func subffix() {
        if let subpaths = NSFileManager.defaultManager().subpathsAtPath(source) {
            for subpath in subpaths {
                if subpath.hasSuffix(fileType) {
                    do {
                        var advance = -fileType.characters.count
                        
                        
                        if subpath.hasSuffix("@2x" + fileType)  {
                            advance -= 3
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + "@2x" + fileType)
                        } else if subpath.hasSuffix("@3x" + fileType) {
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + "@3x" + fileType)
                        } else {
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + fileType)
                        }
                        if rename {
                            try NSFileManager.defaultManager().removeItemAtPath(source + "/" + subpath)
                        }
                    } catch {
                        print("\(subpath) is copy Error.")
                    }
                }
            }
        }
    }
    
    init(source: String, target: String, fileType: String, insert: String, rename: Bool) {
        self.source = source
        self.target = target
        self.insert = insert
        self.fileType = fileType
        self.rename = rename
    }
    
    func run(type: String) {
        switch type {
        case "P", "p", "prefix":
            prefix()
        case "S", "s", "subffix":
            subffix()
        default:
            print("Type Error.")
        }
        print("Rename Done.")
    }
}

var source: String = ""
var target: String = ""
var fileType: String = ".png"
var insert: String = ""
var rename: Bool = true
var type: String = "s"

let path = Process.arguments[0]
//print(path)
for (i, c) in path.characters.reverse().enumerate() {
    if c == "/" {
        //print(path.substringWithRange(path.endIndex.advancedBy(-i) ..< path.endIndex))
        source = path.substringWithRange(path.startIndex ..< path.endIndex.advancedBy(-i))
        target = source
        insert = path.substringWithRange(path.endIndex.advancedBy(-i) ..< path.endIndex)
        break
    }
}

Rename(source: source, target: target, fileType: fileType, insert: insert, rename: rename).run(type)


/** Rename 1.0

class Rename {
    var source: String = "/Users/Myron/Downloads/Source"
    var target: String = "/Users/Myron/Downloads/Target"
    var fileType: String = ".png"
    var insert: String = "_YES_"
    var rename: Bool = false
    
    func prefix() {
        if let subpaths = NSFileManager.defaultManager().subpathsAtPath(source) {
            for subpath in subpaths {
                if subpath.hasSuffix(fileType) {
                    do {
                        try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + insert + subpath)
                        if rename {
                            try NSFileManager.defaultManager().removeItemAtPath(source + "/" + subpath)
                        }
                    } catch {
                        print("\(subpath) is copy Error.")
                    }
                }
            }
        }
    }
    
    func subffix() {
        if let subpaths = NSFileManager.defaultManager().subpathsAtPath(source) {
            for subpath in subpaths {
                if subpath.hasSuffix(fileType) {
                    do {
                        var advance = -fileType.characters.count
                        
                        
                        if subpath.hasSuffix("@2x" + fileType)  {
                            advance -= 3
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + "@2x" + fileType)
                        } else if subpath.hasSuffix("@3x" + fileType) {
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + "@3x" + fileType)
                        } else {
                            try NSFileManager.defaultManager().copyItemAtPath(source + "/" + subpath, toPath: target + "/" + subpath.substringWithRange(subpath.startIndex ..< subpath.endIndex.advancedBy(advance)) + insert + fileType)
                        }
                        if rename {
                            try NSFileManager.defaultManager().removeItemAtPath(source + "/" + subpath)
                        }
                    } catch {
                        print("\(subpath) is copy Error.")
                    }
                }
            }
        }
    }
    
    init(source: String, target: String, fileType: String, insert: String, rename: Bool) {
        self.source = source
        self.target = target
        self.insert = insert
        self.fileType = fileType
        self.rename = rename
    }
    
    func run(type: String) {
        switch type {
        case "P", "p", "prefix":
            prefix()
        case "S", "s", "subffix":
            subffix()
        default:
            print("Type Error.")
        }
        print("Rename Done.")
    }
}

var source: String = ""
var target: String = ""
var fileType: String = ".png"
var insert: String = ""
var rename: Bool = true
var type: String = "s"


let argv = Process.arguments
let argc = Int(Process.argc)

print(argv[0])
//print(argc)
if argc <= 1 {
    print("Argc Error")
    exit(1)
}

var i = 1
while i+1 < argc {
    if i % 2 == 1 {
        switch argv[i] {
        case "-s", "source", "-S":
            source = argv[i+1]
        case "-t", "target", "-T":
            target = argv[i+1]
        case "fileType", "-f", "-F":
            fileType = argv[i+1]
        case "insert", "-i", "-I":
            insert = argv[i+1]
        case "rename", "-r", "-R":
            let r = argv[i+1]
            switch r {
            case "true", "True", "TRUE", "YES", "yes", "Yes", "t", "y":
                rename = true
            default:
                rename = false
            }
        case "type", "-t", "-T":
            type = argv[i+1]
        default:
            print("Argv Error")
            exit(1)
        }
        i += 2
    } else {
        print("i Error")
        exit(1)
    }
    
}

if source.isEmpty || insert.isEmpty{
    print("Data Error")
    exit(1)
}

if target.isEmpty {
    target = source
}

Rename(source: source, target: target, fileType: fileType, insert: insert, rename: rename).run(type)
 */
=======
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
>>>>>>> origin/master
