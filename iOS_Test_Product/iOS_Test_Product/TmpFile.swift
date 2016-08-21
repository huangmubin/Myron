//
//  Explorer.swift
//  资源管理器
//
//  Created by 黄穆斌 on 16/8/19.
//
//

import Foundation

// MARK: - Explorer Cache

/**
 The Cache Manager, default the max cache numbers is 50 and the max cache size is 50MB. You by the maxCount and maxSize set it.
 */
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
    }
    
    // MARK: Propertys
    
    /// LRU Queue
    var queue = [String: Cache]()
    /// The queue's max count.
    var maxCount = 50
    /// The queue's max size, the unit is byte, divide 1000000 is MB.
    var maxSize = 50000000
    
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
    
    /// 文件保存
    private var index: ExplorerIndex!
    /// Cache 缓存
    private var cache: ExplorerCache = ExplorerCache()
    
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
    func save(data: NSData?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil, cache: Bool = true) -> Bool {
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
        if result && cache {
            self.cache.append(<#T##key: String##String#>, value: <#T##AnyObject#>, size: <#T##Int#>)
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

/*
// MARK: - Explorer
class Explorer {
    
    // MARK: Init
    
    /// 单例对象
    static let shared = Explorer()
    private init() {
        if let user = NSUserDefaults(suiteName: "Explorer_File_Index") {
            index = user
        } else {
            NSUserDefaults.standardUserDefaults().addSuiteNamed("Explorer_File_Index")
            index = NSUserDefaults(suiteName: "Explorer_File_Index")
        }
        self.clearTimeout()
    }
    
    // MARK: Property
    
    /// 线程锁
    private var lock: NSLock = NSLock()
    /// 持久目录管理
    private var index: NSUserDefaults!
    
    /// 管理器
    private var manager = NSFileManager.defaultManager()
    /// 持久保存路径
    private var path = "\(NSHomeDirectory())/Documents/Explorer_Folder/"
    
    /// 保存时调用的方法
    var saveAction: ((name: String, folder: String, infos: [String: AnyObject]?) -> Bool)?
    var moveAction: ((name: String, folder: String, toName: String, toFolder: String, infos: [String: AnyObject]?) -> Bool)?
    var copyAction: ((name: String, folder: String, toName: String, toFolder: String, infos: [String: AnyObject]?) -> Bool)?
    var deleteAction: ((name: String, folder: String, infos: [String: AnyObject]?) -> Bool)?
    
    // MARK: - Index 操作
    
    private func insertIndex(name: String, folder: String, time: NSTimeInterval) {
        index.setObject(["name": name, "folder": folder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: folder + name)
    }
    
    private func readIndex(name: String, folder: String) -> NSTimeInterval? {
        if let file = index.objectForKey(folder + name) as? [String: AnyObject] {
            if let time = file["time"] as? Double {
                return time
            }
        }
        return nil
    }
    
    private func changeIndex(name: String, folder: String, time: NSTimeInterval) -> Bool {
        if let _ = index.objectForKey(folder + name) as? [String: AnyObject] {
            index.setObject(["name": name, "folder": folder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: folder + name)
            return true
        }
        return false
    }
    
    private func removeIndex(name: String, folder: String) -> NSTimeInterval? {
        if let time = readIndex(name, folder: folder) {
            index.removeObjectForKey(folder + name)
            return time
        }
        return nil
    }
    
    // MARK: - 文件操作
    
    /// 保存数据
    func save(data: NSData?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        if let data = data {
            if !name.isEmpty {
                var path = self.path + folder
                if createDirectory(path) {
                    path += name
                    var go = true
                    if let action = saveAction {
                        go = action(name: name, folder: folder, infos: infos)
                    }
                    if go {
                        if replace {
                            result = data.writeToFile(path, atomically: true)
                        } else {
                            if manager.fileExistsAtPath(path) {
                                insertIndex(name, folder: folder, time: time)
                                result = true
                            } else {
                                if data.writeToFile(path, atomically: true) {
                                    insertIndex(name, folder: folder, time: time)
                                    result = true
                                }
                            }
                        }
                    }
                }
            }
        }
        lock.unlock()
        return result
    }
    
    /// 获取数据
    func read(name: String, folder: String = "") -> NSData? {
        lock.lock()
        let data = NSData(contentsOfFile: self.path + folder + name)
        lock.unlock()
        return data
    }
    
    /// 检查文件是否存在
    func check(name: String, folder: String = "") -> NSTimeInterval? {
        lock.lock()
        if let time = readIndex(name, folder: folder) {
            return time
        }
        lock.unlock()
        return nil
    }
    
    /// 延长文件保存时间
    func delay(name: String, folder: String = "", time: NSTimeInterval) -> Bool {
        lock.lock()
        let result = changeIndex(name, folder: folder, time: time)
        lock.unlock()
        return result
    }
    
    /// 移动文件
    func move(name: String, folder: String = "", toName: String, toFolder: String = "", infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        let path = folder + name
        let topath = toFolder + name
        if path != topath {
            if createDirectory(self.path + topath) {
                var go = true
                if let action = moveAction {
                    go = action(name: name, folder: folder, toName: toName, toFolder: toFolder, infos: infos)
                }
                if go {
                    do {
                        try manager.moveItemAtPath(self.path + path, toPath: self.path + topath)
                        if let time = removeIndex(name, folder: folder) {
                            insertIndex(toName, folder: toFolder, time: time)
                            result = true
                        }
                    } catch { }
                }
            }
        }
        lock.unlock()
        return result
    }
    
    /// 拷贝文件
    func copy(name: String, folder: String = "", toName: String, toFolder: String = "", time: NSTimeInterval = 0, infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        let path = folder + name
        let topath = toFolder + name
        if path != topath {
            if createDirectory(self.path + topath) {
                var go = true
                if let action = copyAction {
                    go = action(name: name, folder: folder, toName: toName, toFolder: toFolder, infos: infos)
                }
                if go {
                    do {
                        try manager.copyItemAtPath(self.path + path, toPath: self.path + topath)
                        insertIndex(toName, folder: toFolder, time: time)
                        result = true
                    } catch { }
                }
            }
        }
        lock.unlock()
        return result
    }
    
    /// 删除文件
    func delete(name: String, folder: String = "", infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        do {
            var go = true
            if let action = deleteAction {
                go = action(name: name, folder: folder, infos: infos)
            }
            if go {
                if let _ = removeIndex(name, folder: folder) {
                    try manager.removeItemAtPath(self.path + folder + name)
                    result = true
                }
            }
        } catch { }
        lock.unlock()
        return result
    }
    
    // MARK: - Url 连接
    
    func url(name: String, folder: String = "") -> NSURL? {
        lock.lock()
        var url: NSURL? = nil
        if manager.fileExistsAtPath(self.path + folder + name) {
            url = NSURL(string: self.path + folder + name)
        }
        lock.unlock()
        return url
    }
    
    // MARK: - 清理内存方法
    
    func clearTimeout() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            self.lock.lock()
            if let file = NSDictionary(contentsOfFile: "\(NSHomeDirectory())/Library/Preferences/Explorer_File_Index.plist")  {
                let now = NSDate().timeIntervalSince1970
                for (key, value) in file {
                    if let key = key as? String {
                        if let value = value as? [String: AnyObject] {
                            if let time = value["time"] as? Double, let name = value["name"] as? String, let folder = value["folder"] as? String {
                                if time > 0 && time <= now {
                                    if let _ = try? NSFileManager.defaultManager().removeItemAtPath("\(NSHomeDirectory())/Documents/Explorer_File_Index/" + folder + name) {
                                        self.index.removeObjectForKey(key)
                                    }
                                }
                            }
                        } else {
                            self.index.removeObjectForKey(key)
                        }
                    }
                }
            }
            self.lock.unlock()
        }
    }
    
    // MARK: - Tools
    
    /// 检查文件夹是否存在，不存在则创建
    private func createDirectory(path: String) -> Bool {
        if manager.fileExistsAtPath(path) {
            return true
        } else {
            do {
                try manager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }
    }
    

    // MARK: - Class Tools
    
    /// 拼接路径
    class func spliceName(paths: [String]?) -> String {
        guard let paths = paths else { return "" }
        var path = ""
        for p in paths {
            path += "\(p)/"
        }
        return path
    }
    
    /// 获取文件尺寸 MB
    class func sizeForFile(path: String) -> Double {
        var fileSize = 0
        if let attributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(path) {
            if attributes[NSFileType] as? String != NSFileTypeDirectory {
                if let size = attributes[NSFileSize] as? Int {
                    fileSize = size
                }
            }
        }
        return Double(fileSize) / 1000000
    }
    
    /// 获取文件夹大小，MB单位
    class func sizeForFolder(path: String, traverseSub: Bool = true) -> Double {
        var allsize: Int = 0
        var files: [String] = []
        if traverseSub {
            if let file = NSFileManager.defaultManager().subpathsAtPath(path) {
                files = file
            }
        } else {
            if let file = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path) {
                files = file
            }
        }
        for file in files {
            if let attributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(path + file) {
                if attributes[NSFileType] as? String != NSFileTypeDirectory {
                    if let size = attributes[NSFileSize] as? Int {
                        allsize += size
                    }
                }
            }
        }
        return Double(allsize) / 1000000
    }
    
}
*/