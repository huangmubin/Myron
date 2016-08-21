//
//  Explorer.swift
//  资源管理器
//
//  Created by 黄穆斌 on 16/8/19.
//
//

import UIKit

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
        deinit {
            print("key = \(key) deinit.")
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
        size = 0
        first = nil
        last = nil
    }
}

// MARK: - Explorer Index

// MARK: Protocol
/**
 The file index protocol.
 */
protocol ExplorerIndex: NSObjectProtocol {

    /// load
    func loadIndex()
    /// append
    func insertIndex(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]?) -> Bool
    /// change infos
    func changeIndex(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]?) -> Bool
    /// remove infos
    func removeIndex(name: String, folder: String, infos: [String: AnyObject]?) -> Bool
    /// move infos
    func moveIndex(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval, infos: [String: AnyObject]?) -> Bool
    /// delay time
    func delayIndex(folder: String, name: String, time: NSTimeInterval) -> Bool
    /// read infos
    func readIndexes() -> [(name: String, folder: String, time: NSTimeInterval, infos: [String: AnyObject]?)]
    
}

// MARK: ExplorerUserDefault

class ExplorerUserDefault: NSObject, ExplorerIndex {
    
    static let shared: ExplorerUserDefault = ExplorerUserDefault()
    private override init() {
        super.init()
    }
    
    /// Explorer_File_Index.plist
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
    
    func moveIndex(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval = 0, infos: [String: AnyObject]?) -> Bool {
        suite.removeObjectForKey(folder + name)
        suite.setObject(["name": toName, "folder": toFolder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: toFolder + toName)
        return true
    }
    
    func delayIndex(folder: String, name: String, time: NSTimeInterval) -> Bool {
        if suite.objectForKey(folder + name) != nil {
            suite.setObject(["name": name, "folder": folder, "time": time == 0 ? 0 : NSDate().timeIntervalSince1970 + time], forKey: folder + name)
            return true
        }
        return false
    }
    
    func readIndexes() -> [(name: String, folder: String, time: NSTimeInterval, infos: [String : AnyObject]?)] {
        var results = [(name: String, folder: String, time: NSTimeInterval, infos: [String : AnyObject]?)]()
        var invalidateKey = [String]()
        if let file = NSDictionary(contentsOfFile: "\(NSHomeDirectory())/Library/Preferences/Explorer_File_Index.plist") {
            for (k, o) in file {
                let key = k as! String
                let value = o as! [String: AnyObject]
                if let name = value["name"] as? String, let folder = value["folder"] as? String, let time = value["time"] as? NSTimeInterval {
                    results.append((name, folder, time, nil))
                } else {
                    invalidateKey.append(key)
                }
            }
        }
        for key in invalidateKey {
            suite.removeObjectForKey(key)
        }
        return results
    }
    
}

// MARK: - Explorer

/**
 The File Manager. Can be easy to save/read/move/delete file and automatic manager the cache. 
 Default file is save to NSHomeDirectory()/Documents/Explorer_Folder/..., you can change it use the path property.
 Default index object is it ExplorerUserDefault.shared, user the .plist file to save the file list. You can create the object use the ExplorerIndex protocol and it's index property. Then use the SQlite or CoreData or other to manager the file list.
 */
class Explorer: NSObject {
    
    // MAKR: Init
    
    static let shared = Explorer()
    private override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clearCache), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clearTemporary), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clearTemporary), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        index = ExplorerUserDefault.shared
        index.loadIndex()
        clearTemporary()
    }
    class func loaded() {
        shared.clearCache()
    }
    
    // MARK: Lock
    
    /// The Lock package.
    private struct Lock {
        var lock_semaphore: dispatch_semaphore_t = dispatch_semaphore_create(1)
        func lock() { dispatch_semaphore_wait(lock_semaphore, DISPATCH_TIME_FOREVER) }
        func unlock() { dispatch_semaphore_signal(lock_semaphore) }
    }
    
    private var lock: Lock = Lock()
    
    // MARK: Property
    
    /// File list index manager. Default self.
    private weak var index: ExplorerIndex!
    /// Cache manager.
    var cache: ExplorerCache = ExplorerCache()
    /// Will you need to open the explorer cache? Default true.
    var openCache: Bool = true {
        didSet {
            if !openCache {
                cache.clearCache()
            }
        }
    }
    
    /// NSFileManager.defaultManager()
    private var manager = NSFileManager.defaultManager()
    /// File save path. Default is NSHomeDirectory()/Documents/Explorer_Folder/...
    private var path = "\(NSHomeDirectory())/Documents/Explorer_Folder/"
    
    // MARK: - File Manager methods.
    
    /// Save file.
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
            if index.insertIndex(name, folder: folder, time: time, infos: infos) {
                result = data.writeToFile(path, atomically: true)
            }
        } else {
            if manager.fileExistsAtPath(path) {
                result = index.changeIndex(name, folder: folder, time: time, infos: infos)
            } else {
                if index.insertIndex(name, folder: folder, time: time, infos: infos) {
                    if data.writeToFile(path, atomically: true) {
                        result = true
                    } else {
                        index.removeIndex(name, folder: folder, infos: infos)
                    }
                }
            }
        }
        
        if openCache && cache && result {
            self.cache.append(folder + name, value: data, size: data.length)
        }
        
        lock.unlock()
        return result
    }
    
    /// Read file.
    func read(folder: String = "", name: String) -> NSData? {
        lock.lock()
        var value: NSData? = nil
        if openCache {
            if let object = cache.read(folder + name) as? NSData {
                value = object
            } else {
                value = NSData(contentsOfFile: path + folder + name)
                if value != nil {
                    cache.append(folder + name, value: value!, size: value!.length)
                }
            }
        } else {
            value = NSData(contentsOfFile: path + folder + name)
        }
        lock.unlock()
        return value
    }
    
    /// Remove file.
    func remove(folder: String = "", name: String, infos: [String: AnyObject]? = nil) {
        lock.lock()
        if index.removeIndex(name, folder: folder, infos: infos) {
            if openCache {
                cache.remove(folder + name)
            }
            let _ = try? manager.removeItemAtPath(path + folder + name)
        }
        lock.unlock()
    }
    
    /// Move file
    func move(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval, infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        if Explorer.createDirectory(self.path + toFolder + toName) {
            if index.moveIndex(folder, name: name, toFolder: toFolder, toName: toName, time: time, infos: infos) {
                do {
                    try manager.moveItemAtPath(folder + name, toPath: toFolder + toName)
                    result = true
                } catch {
                    index.moveIndex(toFolder, name: toName, toFolder: folder, toName: name, time: time, infos: infos)
                }
            }
        }
        lock.unlock()
        return result
    }
    
    /// Copy file
    func copy(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval, infos: [String: AnyObject]? = nil) -> Bool {
        lock.lock()
        var result = false
        if Explorer.createDirectory(self.path + toFolder + toName) {
            if index.insertIndex(toName, folder: toFolder, time: time, infos: infos) {
                do {
                    try manager.copyItemAtPath(folder + name, toPath: toFolder + toName)
                    result = true
                } catch {
                    index.removeIndex(toName, folder: toFolder, infos: infos)
                }
            }
        }
        lock.unlock()
        return result
    }
    
    // MARK: Specific Data Tool
    
    /// Read the file if it is a Image Data
    func readImage(folder: String = "", name: String) -> UIImage? {
        lock.lock()
        var image: UIImage? = nil
        if openCache {
            if let data = cache.read(folder + name) as? NSData {
                image = UIImage(data: data)
            } else {
                if let data = NSData(contentsOfFile: path + folder + name) {
                    image = UIImage(data: data)
                    if image != nil {
                        cache.append(folder + name, value: data, size: data.length)
                    }
                }
            }
        } else {
            if let data = NSData(contentsOfFile: path + folder + name) {
                image = UIImage(data: data)
            }
        }
        lock.unlock()
        return image
    }
    
    /// Save UIImage.
    func saveImage(image: UIImage?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil, cache: Bool = true) -> Bool {
        lock.lock()
        
        // 数据检查
        var value: NSData?
        if let image = image {
            if let png = UIImagePNGRepresentation(image) {
                value = png
            }
        }
        guard let data = value else { lock.unlock(); return false }
        
        // 路径检查
        let path = self.path + folder + name
        guard Explorer.isFilenameValid(path) else { lock.unlock(); return false }
        guard Explorer.createDirectory(self.path + folder) else { lock.unlock(); return false }
        
        // 文件写入
        var result = false
        if replace {
            if index.insertIndex(name, folder: folder, time: time, infos: infos) {
                result = data.writeToFile(path, atomically: true)
            }
        } else {
            if manager.fileExistsAtPath(path) {
                result = index.changeIndex(name, folder: folder, time: time, infos: infos)
            } else {
                if index.insertIndex(name, folder: folder, time: time, infos: infos) {
                    if data.writeToFile(path, atomically: true) {
                        result = true
                    } else {
                        index.removeIndex(name, folder: folder, infos: infos)
                    }
                }
            }
        }
        
        if openCache && cache && result {
            self.cache.append(folder + name, value: data, size: data.length)
        }
        
        lock.unlock()
        return result
    }
    
    // MARK: Path and Url
    
    /// Get file path.
    func path(folder: String = "", name: String) -> String? {
        lock.lock()
        var path: String? = self.path + folder + name
        if !manager.fileExistsAtPath(path!) {
            path = nil
        }
        lock.unlock()
        return path
    }
    
    /// Get file url.
    func url(folder: String = "", name: String) -> NSURL? {
        lock.lock()
        var url: NSURL?
        let path = self.path + folder + name
        if manager.fileExistsAtPath(path) {
            url = NSURL(fileURLWithPath: path)
        }
        lock.unlock()
        return url
    }
    
    // MARK: Delay
    
    /// Delay tmp file time.
    func delay(folder: String = "", name: String, time: NSTimeInterval) -> Bool {
        lock.lock()
        var result = false
        if index.delayIndex(folder, name: name, time: time) {
            result = true
        }
        lock.unlock()
        return result
    }
    
    // MARK: Clear
    
    /// Clear the time out file.
    func clearTemporary() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.lock.lock()
            let time = NSDate().timeIntervalSince1970
            for value in self.index.readIndexes() {
                if value.time > 0 && value.time < time {
                    if self.index.removeIndex(value.name, folder: value.folder, infos: value.infos) {
                        let _ = try? NSFileManager.defaultManager().removeItemAtPath(self.path + value.folder + value.name)
                    }
                }
            }
            self.lock.unlock()
        }
    }
    
    /// Clear all the file.
    func clearAll() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.lock.lock()
            for value in self.index.readIndexes() {
                self.index.removeIndex(value.name, folder: value.folder, infos: value.infos)
            }
            let _ = try? NSFileManager.defaultManager().removeItemAtPath(self.path)
            Explorer.createDirectory(self.path)
            self.lock.unlock()
        }
    }
    
    /// Clear cache.
    func clearCache() {
        cache.clearCache()
    }
    
    // MARK: - Tools
    
    /// Check the folder has. If no, create it.
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
    
    /// Is the path valid?
    class func isFilenameValid(path: String) -> Bool {
        return true
    }
    
    
    /// Count the file size, use MB unit.
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
    
    /// Count the folder size, use MB unit.
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