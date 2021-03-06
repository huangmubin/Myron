
# Explorer.swift

资源管理器工具。用于自动化处理文件保存，管理，删除以及缓存问题。

# Api

> Api 设计规则
> 
> 

    func save(data: NSData?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil, cache: Bool = true) -> Bool
    func read(folder: String = "", name: String) -> NSData?
    func remove(folder: String = "", name: String, infos: [String: AnyObject]? = nil)
    func move(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval, infos: [String: AnyObject]? = nil) -> Bool
    func copy(folder: String, name: String, toFolder: String, toName: String, time: NSTimeInterval, infos: [String: AnyObject]? = nil) -> Bool
    // MARK: Specific Data Tool
    func readImage(folder: String = "", name: String) -> UIImage?
    func saveImage(image: UIImage?, name: String, time: NSTimeInterval = 0, folder: String = "", replace: Bool = false, infos: [String: AnyObject]? = nil, cache: Bool = true) -> Bool
    // MARK: Path and Url
    func path(folder: String = "", name: String) -> String?
    func url(folder: String = "", name: String) -> NSURL?
    // MARK: Delay
    func delay(folder: String = "", name: String, time: NSTimeInterval) -> Bool
    // MARK: Clear
    func clearTemporary()
    func clearAll()
    func clearCache()
    class func createDirectory(path: String) -> Bool
    class func isFilenameValid(path: String) -> Bool
    class func sizeForFile(path: String) -> Double
    class func sizeForFolder(path: String, traverseSub: Bool = true) -> Double


# 设计思路

* 通过一个单例类来进行文件系统的管理，开发时不再需要考虑文件夹，文件的创建以及归档问题。
* 缓存文件自动清理。
* 使用 NSUserDefault 进行文件目录索引。
    * 备选方案：SQLite, CoreData (当前设计目的为轻量级文件管理系统，暂不考虑数据库使用)
* 使用 dispatch_semaphore_t 信号量进行加锁，确保线程安全。
* 实现功能
    * 保存
        * 持久存储
        * 临时存储
    * 读取
        * 磁盘读取
        * 内存读取
    * 删除
    * 移动
* 使用场景
    * 应用当中有获取图片，视频等文件，需长期保存。
    * 网络缓存图片，文件，需一段时间之后进行删除。
* 其他考虑
    * 由于过于轻量，可能会根据实际使用场景，与数据库进行配合使用。因此需预留接口。

## 来源

YYCache 等缓存库的学习和了解。以及工作当中对数据的存储需求，让我开始考虑，能否有更加简易的方式来进行应用文件系统的管理，让其更加模块化，操作更加简易，并且无序我过多的考虑缓存问题。

## 流程

* 缓存结构
    * 上级
    * 下级
    * 对象

* 保存(数据，名称，路径，时长，是否覆盖原有文件，是否缓存)
    * 确认数据不为空
    * 确认名称及路径合法
    * 进行目录存储
        * 失败：退出
    * 进行数据存储
        * 失败：进行目录删除，退出
    * 加入缓存列表

* 读取(名称，路径，是否缓存)
    * 从缓存中读取
        * 成功则退出，并把缓存位置提前
    * 从磁盘中读取

* 删除(名称，路径)
    * 从缓存中删除
    * 从磁盘中删除

* 移动(名称，路径，新名称，新路径，是否缓存)
    * 从磁盘移动
    * 加入缓存

* 拷贝

* 延时

## 设计原则

* 轻量化
* 简易
* 低耦合，高兼容性

# 更新记录

* 2016-08-19 创建文件以及初步实现方式
* 2016-08-20 了解更多有关缓存库的构成，构思想法

