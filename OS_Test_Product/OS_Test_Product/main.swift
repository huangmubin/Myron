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

// MARK: - Explorer Delegate
protocol ExplorerIndex {
    /// 文件索引对象加载程序
    func loadIndex()
    /// 新增索引
    func insertIndex(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]?) -> Bool
    /// 改变索引
    func changeIndex(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]?) -> Bool
    /// 移除索引
    func removeIndex(name: String, folder: String, infos: [String: AnyObject]?) -> Bool
}

// MARK: - Explorer
class Explorer: ExplorerIndex {
    
    // MAKR: Init
    
    static let shared = Explorer()
    private init() {
        index = self
        index.loadIndex()
    }
    
    // MARK: Lock
    
    private struct Lock {
        var lock_semaphore: dispatch_semaphore_t = dispatch_semaphore_create(1)
        func lock() { dispatch_semaphore_wait(lock_semaphore, DISPATCH_TIME_FOREVER) }
        func unlock() { dispatch_semaphore_signal(lock_semaphore) }
    }
    
    private var lock: Lock = Lock()
    
    // MARK: Property
    
    private var index: ExplorerIndex!
    
    /// 管理器
    private var manager = NSFileManager.defaultManager()
    /// 持久保存路径
    private var path = "\(NSHomeDirectory())/Documents/Explorer_Folder/"
    
    // MARK: - ExplorerIndex
    
    private var suite: NSUserDefaults!
    
    
    func loadIndex() {
        if let user = NSUserDefaults(suiteName: "Explorer_File_Index") {
            suite = user
        } else {
            NSUserDefaults.standardUserDefaults().addSuiteNamed("Explorer_File_Index")
            suite = NSUserDefaults(suiteName: "Explorer_File_Index")
        }
    }
    
    func insertIndex(name: String, folder: String, time: NSTimeInterval = 0, infos: [String: AnyObject]? = nil) -> Bool {
        suite.setObject(["name": name, "folder": folder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: folder + name)
        return true
    }
    
    func changeIndex(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]? = nil) -> Bool {
        if let _ = suite.objectForKey(folder + name) as? [String: AnyObject] {
            suite.setObject(["name": name, "folder": folder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: folder + name)
            return true
        }
        return false
    }
    
    func removeIndex(name: String, folder: String, infos: [String: AnyObject]? = nil) -> Bool {
        suite.removeObjectForKey(folder + name)
        return true
    }
    
    
    // MARK: - 文件操作
    
    /// 保存数据
    func save(data: NSData?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        
        // 数据检查
        guard let data = data else { lock.unlock(); return false }
        
        // 路径检查
        let path = self.path + folder + name
        guard Explorer.isFilenameValid(path) else { lock.unlock(); return false }
        guard Explorer.createDirectory(self.path + folder) else { lock.unlock(); return false }
        
        // 文件写入
        var result = false
        if replace {
            result = data.writeToFile(path, atomically: true)
        } else {
            if manager.fileExistsAtPath(path) {
                result = index.changeIndex(name, folder: folder, time: time, infos: infos)
            } else {
                if data.writeToFile(path, atomically: true) {
                    if index.insertIndex(name, folder: folder, time: time, infos: infos) {
                        result = true
                    } else {
                        do {
                            try manager.removeItemAtPath(path)
                        } catch {}
                    }
                }
            }
        }
        lock.unlock()
        return result
    }
    
    
    
    // MARK: - Tools
    
    /// 检查文件夹是否存在，不存在则创建
    class func createDirectory(path: String) -> Bool {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            return true
        } else {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }
    }
    
    /// 检查文件名是否合法
    class func isFilenameValid(path: String) -> Bool {
        return true
    }
}






print("Done")