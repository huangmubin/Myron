//
//  Network.swift
//  
//
//  Created by 黄穆斌 on 16/8/4.
//
//

import Foundation

// MARK: - Protocol
protocol NetworkDelegate: NSObjectProtocol {
    func networkDidReceiveResponse(task: Network.Task, completionHandler: (NSURLSessionResponseDisposition) -> Void)
    func networkDidReceiveData(task: Network.Task)
    func networkDidCompleteWithError(task: Network.Task, didCompleteWithError error: NSError?)
}

// MARK: - Network

// MARK: - Network Data
public class Network: NSObject {
    
    // MARK: Task Data Struct
    public class Task {
        var name: String
        var data: NSMutableData?
        var task: NSURLSessionTask?
        var response: NSURLResponse?
        
        var taskReceive: ((task: Task) -> Void)?
        var receive: ((name: String, data: NSMutableData?) -> Void)?
        var complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?
        var httpResponse: ((response: Response) -> Void)?
        
        init(name: String, data: NSMutableData? = nil) {
            self.name = name
            self.data = data
        }
    }
    
    // MARK: Link Network Data Struct
    
    public class LinkTask {
        enum LinkTaskResponse {
            case task((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> NSURLRequest?)
            case response((response: Response) -> NSURLRequest?)
        }
        
        var queue: NSOperationQueue = NSOperationQueue()
        var session: NSURLSession!
        var request: NSURLRequest?
        var name: String
        var tasks: [LinkTaskResponse] = []
        
        //
        init(name: String) {
            queue.maxConcurrentOperationCount = 1
            session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: queue)
            self.name = name
        }
        
        deinit {
            print("LinkTask deinit")
        }
    }
    
    // MARK: 响应结构
    
    public class Response {
        var name: String!
        var data: NSData?
        var response: NSURLResponse?
        var error: NSError?
        
        var code: Int = 0
        var headers: [NSObject: AnyObject] = [:]
        
        
        // MARK: Json
        
        var json: Json
        
        // MARK: Init
        init() {
            json = Json(nil)
        }
        
        init(name: String, data: NSData?, response: NSURLResponse?, error: NSError?) {
            self.name = name
            self.data = data
            self.error = error
            
            if let http = response as? NSHTTPURLResponse {
                self.headers = http.allHeaderFields
                self.code = http.statusCode
            }
            
            json = Json(data)
        }
        
        // 下标访问
        subscript(keys: String...) -> String {
            for key in keys {
                json[key]
            }
            return json.type("")
        }
    }
    
    // MARK: Init
    
    override init() {
        super.init()
        queue.maxConcurrentOperationCount = 1
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: queue)
    }
    
    // MARK: Values
    
    private var queue = NSOperationQueue()
    var session: NSURLSession!
    var tasks = [Task]()
    weak var delegate: NetworkDelegate?
    
    /// 任务链对象
    var linkTask: LinkTask?
    
}

// MARK: - Methods: Task Operations
extension Network {
    
    /// 添加下载任务
    func add(task: Task, request: NSURLRequest) {
        queue.addOperationWithBlock {
            // guard !self.tasks.contains({ $0.name == task.name }) else { return }
            // task.task = self.session.dataTaskWithRequest(request)
            // task.task?.taskDescription = task.name
            // self.tasks.append(task)
            if let index = self.tasks.indexOf({ $0.name == task.name }) {
                let task = self.tasks.removeAtIndex(index)
                self.tasks.insert(task, atIndex: 0)
            } else {
                task.task = self.session.dataTaskWithRequest(request)
                task.task?.taskDescription = task.name
                self.tasks.append(task)
            }
        }
    }
    
    /// 开始下载任务
    func resume(task: Task) {
        queue.addOperationWithBlock {
            task.task?.resume()
        }
    }
    
    /// 暂停下载任务
    func suspend(task: Task) {
        queue.addOperationWithBlock {
            task.task?.suspend()
        }
    }
    
    /// 取消下载任务
    func cancel(task: Task) {
        queue.addOperationWithBlock {
            task.task?.cancel()
        }
    }
    
    /// 是否在下载中
    func loading(name: String) -> Bool {
        if let index = self.tasks.indexOf({ $0.name == name }) {
            return self.tasks[index].task?.state == NSURLSessionTaskState.Running
        }
        return false
    }
    
    func operation(operation: (Task)->Void, name: String) {
        queue.addOperationWithBlock {
            if let index = self.tasks.indexOf({ $0.name == name }) {
                operation(self.tasks[index])
            }
        }
    }
}

// MARK: - Methods: Download
extension Network {
    
    func download(name: String, url: String, method: String = "GET", data: NSData? = nil, header: [String: String]? = nil, body: NSData? = nil, receive: ((name: String, data: NSMutableData?) -> Void)? = nil, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)? = nil) -> Task? {
        
        guard let request = Network.request(url, method: method, header: header, body: body, time: nil) else { return nil }
        
        let task = Task(name: name, data: data == nil ? NSMutableData() : NSMutableData(data: data!))
        
        if data != nil {
            if header == nil {
                request.allHTTPHeaderFields = ["Range": "bytes=\(data!.length)-"]
            } else {
                request.allHTTPHeaderFields!["Range"] = "bytes=\(data!.length)-"
            }
        }
        
        task.receive  = receive
        task.complete = complete
        add(task, request: request)
        resume(task)
        return task
    }
    
    func GET(name: String, url: String, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        if download(name, url: url, method: "GET", data: nil, header: nil, receive: nil, complete: complete) == nil {
            complete?(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "GET", "message": "Task Create Error"]))
        }
    }
    
    func GET(name: String, url: String, header: [String: String]?, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        if download(name, url: url, method: "GET", data: nil, header: header, receive: nil, complete: complete) == nil {
            complete?(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "GET", "message": "Task Create Error"]))
        }
    }
    
    func POST(name: String, url: String, header: [String: String]?, body: NSData?, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        if download(name, url: url, method: "POST", data: nil, header: header, body: body, receive: nil, complete: complete) == nil {
            complete?(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "POST", "message": "Task Create Error"]))
        }
    }
    
    func PUT(name: String, url: String, header: [String: String]?, body: NSData?, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        if download(name, url: url, method: "PUT", data: nil, header: header, body: body, receive: nil, complete: complete) == nil {
            complete?(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "PUT", "message": "Task Create Error"]))
        }
    }
    
    func DELETE(name: String, url: String, header: [String: String]?, body: NSData?, complete: ((name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)?) {
        if download(name, url: url, method: "DELETE", data: nil, header: header, body: body, receive: nil, complete: complete) == nil {
            complete?(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "DELETE", "message": "Task Create Error"]))
        }
    }
}


// MARK: - Methods: Response Order

extension Network {
    
    func downloadResponse2(name: String,
                          url: String,
                          method: String = "GET",
                          data: NSData? = nil,
                          header: [String: String]? = nil,
                          body: NSData? = nil,
                          taskReceive: ((task: Task) -> Void)?,
                          complete: ((response: Response) -> Void)?) -> Task?
    {
        
        guard let request = Network.request(url, method: method, header: header, body: body, time: nil) else { return nil }
        
        let task = Task(name: name, data: data == nil ? NSMutableData() : NSMutableData(data: data!))
        
        if data != nil {
            if header == nil {
                request.allHTTPHeaderFields = ["Range": "bytes=\(data!.length)-"]
            } else {
                request.allHTTPHeaderFields!["Range"] = "bytes=\(data!.length)-"
            }
        }
        
        task.taskReceive  = taskReceive
        task.httpResponse = complete
        add(task, request: request)
        resume(task)
        return task
    }
    
    func downloadResponse(name: String,
                  url: String,
                  method: String = "GET",
                  data: NSData? = nil,
                  header: [String: String]? = nil,
                  body: NSData? = nil,
                  receive: ((name: String, data: NSMutableData?) -> Void)? = nil,
                  complete: ((response: Response) -> Void)?) -> Task?
    {
        
        guard let request = Network.request(url, method: method, header: header, body: body, time: nil) else { return nil }
        
        let task = Task(name: name, data: data == nil ? NSMutableData() : NSMutableData(data: data!))
        
        if data != nil {
            if header == nil {
                request.allHTTPHeaderFields = ["Range": "bytes=\(data!.length)-"]
            } else {
                request.allHTTPHeaderFields!["Range"] = "bytes=\(data!.length)-"
            }
        }
        
        task.receive  = receive
        task.httpResponse = complete
        add(task, request: request)
        resume(task)
        return task
    }
    
    func Get(name: String, url: String, completed: ((response: Response) -> Void)?) {
        if downloadResponse(name, url: url, method: "GET", data: nil, header: nil, receive: nil, complete: completed) == nil {
            completed?(response: Response(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "GET", "message": "Task Create Error"])))
        }
    }
    
    func Get(name: String, url: String, header: [String: String]?, completed: ((response: Response) -> Void)?) {
        if downloadResponse(name, url: url, method: "GET", data: nil, header: header, receive: nil, complete: completed) == nil {
            completed?(response: Response(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "GET", "message": "Task Create Error"])))
        }
    }
    
    func Post(name: String, url: String, header: [String: String]? = nil, body: NSData?, completed: ((response: Response) -> Void)?) {
        if downloadResponse(name, url: url, method: "POST", data: nil, header: header, body: body, receive: nil, complete: completed) == nil {
            completed?(response: Response(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "POST", "message": "Task Create Error"])))
        }
    }
    
    func Put(name: String, url: String, header: [String: String]?, body: NSData?, completed: ((response: Response) -> Void)?) {
        if downloadResponse(name, url: url, method: "PUT", data: nil, header: header, body: body, receive: nil, complete: completed) == nil {
            completed?(response: Response(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "PUT", "message": "Task Create Error"])))
        }
    }
    
    func Delete(name: String, url: String, header: [String: String]?, body: NSData?, completed: ((response: Response) -> Void)?) {
        if downloadResponse(name, url: url, method: "DELETE", data: nil, header: header, body: body, receive: nil, complete: completed) == nil {
            completed?(response: Response(name: name, data: nil, response: nil, error: NSError(domain: "Task Create Error", code: 0, userInfo: ["name":name, "url": url, "type": "DELETE", "message": "Task Create Error"])))
        }
    }
}

// MARK: - NSURLSessionDelegate
extension Network: NSURLSessionDelegate {
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        let index = tasks.indexOf({ dataTask.taskDescription == $0.name })!
        tasks[index].response = response
        if delegate == nil {
            completionHandler(.Allow)
        } else {
            delegate?.networkDidReceiveResponse(tasks[index], completionHandler: completionHandler)
        }
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let index = tasks.indexOf({ dataTask.taskDescription == $0.name })!
        let task  = tasks[index]
        task.data?.appendData(data)
        task.taskReceive?(task: task)
        task.receive?(name: task.name, data: task.data)
        delegate?.networkDidReceiveData(tasks[index])
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let index = tasks.indexOf({ task.taskDescription == $0.name })!
        let task = tasks.removeAtIndex(index)
        task.complete?(name: task.name, data: task.data, response: task.response, error: error)
        task.httpResponse?(response: Response(name: task.name, data: task.data, response: task.response, error: error))
        delegate?.networkDidCompleteWithError(task, didCompleteWithError: error)
    }
    
}

// MARK: - Link Task 任务链方法

extension Network {
        
    /// 创建任务链
    func linkTask(name: String, type: Bool = false) -> Network {
        if let link = linkTask {
            link.tasks.removeAll()
        }
        linkTask = LinkTask(name: name)
        return self
    }
    
    /// 创建任务链初始请求
    func linkRequest(path: String, method: String = "GET", header: [String: String]? = nil, body: NSData? = nil, time: NSTimeInterval? = nil) -> Network {
        self.linkTask?.request = Network.request(path, method: method, header: header, body: body, time: time)
        return self
    }
    
    /// 添加任务链下载任务回调
    func linkAddTask(block: (name: String, data: NSData?, response: NSURLResponse?, error: NSError?) -> NSURLRequest?) -> Network {
        self.linkTask?.tasks.append(LinkTask.LinkTaskResponse.task(block))
        return self
    }
    
    /// 添加任务链下载任务回调
    func linkAddTaskR(block: (response: Response) -> NSURLRequest?) -> Network {
        self.linkTask?.tasks.append(LinkTask.LinkTaskResponse.response(block))
        return self
    }
    
    /// 启动任务链
    func linkTaskResume() {
        if let link = linkTask, let request = linkTask?.request {
            link.session.dataTaskWithRequest(request) { [weak self] (data, response, error) in
                if link.tasks.count > 0 {
                    let block = link.tasks.removeFirst()
                    switch block {
                    case .task(let block):
                        if let newRequest = block(name: link.name, data: data, response: response, error: error) {
                            self?.linkTask?.request = newRequest
                            self?.linkTaskResume()
                            return
                        }
                    case .response(let block):
                        if let newRequest = block(response: Response(name: link.name, data: data, response: response, error: error)) {
                            self?.linkTask?.request = newRequest
                            self?.linkTaskResume()
                            return
                        }
                    }
                }
                self?.linkTask?.tasks.removeAll()
                self?.linkTask = nil
            }.resume()
        }
    }
}

// MARK: - Tools
extension Network {
    
    // MARK: Request
    
    /// 创建 Request
    class func request(path: String,
                     method: String,
                     header: [String: String]?  = nil,
                       body: NSData?            = nil,
                       time: NSTimeInterval?    = nil
        ) -> NSMutableURLRequest? {
        
        guard let url = NSURL(string: path) else { return nil }
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = method
        request.HTTPBody = body
        
        if let header = header {
            for (key, value) in header {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let time = time {
            request.timeoutInterval = time
        }
        
        return request
    }
    
    // MARK: Encode
    
    class func encodeURLComponent(url: String?) -> String? {
        return url?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "?!@#$^&%*+,:;='\"`<>()[]{}/\\| ").invertedSet)
    }
    
    // MARK: Data
    
    /// 获取状态码
    class func statusCode(response: NSURLResponse?) -> Int {
        if let http = response as? NSHTTPURLResponse {
            return http.statusCode
        }
        return 0
    }
    
    
    /// 获取所有头数据
    class func allHeaderFields(response: NSURLResponse?) -> [NSObject:AnyObject] {
        if let http = response as? NSHTTPURLResponse {
            return http.allHeaderFields
        }
        return [:]
    }
    
    /// 把 NSData 转换成 Json 数据
    class func json(data: NSData?) -> AnyObject? {
        if let json = data {
            if let jsonData = try? NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.AllowFragments) {
                return jsonData
            }
        }
        return nil
    }
    
    /// 把 NSData 转换成 Json 数据，并提取其中某个 Key 对应的 Value 值。
    class func json(data: NSData?, key: String) -> AnyObject? {
        if let json = json(data) as? [String:AnyObject] {
            if let value = json[key] {
                return value
            }
        }
        return nil
    }
    
    /// 把 Json 数据转存成 NSData
    class func data(json: AnyObject) -> NSData? {
        if let data = try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted) {
            return data
        }
        return nil
    }
    
    
    /// 格式化 Json 字符串
    class func jsonFormat(json: String) -> String {
        var _space = 0
        var space: String {
            var s = ""
            for _ in 0 ..< _space {
                s += "    "
            }
            return s
        }
        var type = true
        var result = json
        result.removeAll(keepCapacity: true)
        
        for c in json.characters {
            if type {
                switch c {
                case "\"":
                    result.append(c)
                    type = false
                case ",":
                    result.append(c)
                    result += "\n" + space
                case "{", "[":
                    result.append(c)
                    _space += 1
                    result += "\n" + space
                case "}", "]":
                    _space -= 1
                    result += "\n" + space
                    result.append(c)
                default:
                    result.append(c)
                }
            } else {
                result.append(c)
                if c == "\"" {
                    type = true
                }
            }
        }
        return result
    }

    
}

// MARK: - Json 数据处理
class Json {
    
    // MARK: Value
    /// 数据
    var json: AnyObject? {
        didSet {
            result = json
        }
    }
    var result: AnyObject?
    
    // MARK: Init
    
    init(_ data: NSData?) {
        if let data = data {
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) {
                self.json = json
                self.result = json
            }
        }
    }
    init(_ data: AnyObject) {
        json = data
        result = data
    }
    
    // 下标访问，返回 Json 数据
    subscript(keys: AnyObject...) -> Json {
        var tmp: AnyObject? = result
        for (i, key) in keys.enumerate() {
            if i == keys.count-1 {
                if let data = tmp as? [String: AnyObject], let v = key as? String {
                    result = data[v]
                    continue
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        result = data[v]
                        continue
                    }
                }
            } else {
                if let data = tmp as? [String: AnyObject], let v = key as? String  {
                    tmp = data[v]
                    continue
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        tmp = data[v]
                        continue
                    }
                }
            }
            tmp = nil
        }
        return self
    }
    
    // MARK: 函数访问
    
    // MARK: 访问 result 方法
    var int: Int? {
        let value = result as? Int
        result = json
        return value
    }
    var double: Double? {
        let value = result as? Double
        result = json
        return value
    }
    var string: String? {
        let value = result as? String
        result = json
        return value
    }
    var array: [Json] {
        if let value = result as? [AnyObject] {
            result = json
            var arr = [Json]()
            for v in value {
                arr.append(Json(v))
            }
            return arr
        }
        result = json
        return []
    }
    
    var dictionary: [String: Json] {
        if var value = result as? [String: AnyObject] {
            result = json
            for (k, v) in value {
                value[k] = Json(v)
            }
            return value as! [String: Json]
        }
        result = json
        return [:]
    }
    func type<T>(null: T) -> T {
        if let v = result as? T {
            result = json
            return v
        } else {
            result = json
            return null
        }
    }
    
    // MARK: 直接访问方法
    
    /// 根据字符串列表逐步解压，最后解压出来 [AnyObject] 格式。
    func array(keys: AnyObject...) -> [AnyObject] {
        var tmp: AnyObject? = json
        for (i, key) in keys.enumerate() {
            if i == keys.count-1 {
                if let data = tmp as? [String: AnyObject], let v = key as? String {
                    return (data[v] as? [AnyObject]) ?? []
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        return (data[v] as? [AnyObject]) ?? []
                    }
                }
            } else {
                if let data = tmp as? [String: AnyObject], let v = key as? String  {
                    tmp = data[v]
                    break
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        tmp = data[v]
                        break
                    }
                }
            }
            tmp = nil
        }
        return []
    }
    
    /// 根据 null 的字符串类型，按照 keys 逐步解压出 T 类型的字段，如果解压不到则返回 null 参数
    func value<T>(type: T, _ keys: AnyObject...) -> T {
        var tmp: AnyObject? = json
        for (i, key) in keys.enumerate() {
            if i == keys.count-1 {
                if let data = tmp as? [String: AnyObject], let v = key as? String {
                    return (data[v] as? T) ?? type
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        return (data[v] as? T) ?? type
                    }
                }
            } else {
                if let data = tmp as? [String: AnyObject], let v = key as? String  {
                    tmp = data[v]
                    break
                } else if let data = tmp as? [AnyObject], let v = key as? Int {
                    if v < data.count {
                        tmp = data[v]
                        break
                    }
                }
            }
            tmp = nil
        }
        return type
    }
    
    // MARK: 等待废除
    
    /// 根据 Key 解压出 String 字段，如果解压不到则返回空字符串
    func value(key: String, _ null: String = "") -> String {
        if let dic = json as? [String: AnyObject] {
            if let value = dic[key] as? String {
                return value
            }
        }
        return null
    }
    
    /// 根据 Key 解压出 T 类型字段，如果解压不到则返回 null 参数
    func value<T>(key: String, _ null: T) -> T {
        if let dic = json as? [String: AnyObject] {
            if let value = dic[key] as? T {
                return value
            }
        }
        return null
    }
    
}

// MARK: - Json Model

/**
 Json 数据对象化基类。
 使用方法:
 1. 根据 Json 内容格式建立继承自 JsonModel 的子类。
 2. 设置 JsonModel.types; 该值为子对象数据类型的键值对，比如 result 字段要解析成 BClass 或 [BClass], 则需要添加 ["result": BClass()] 键值对。否则将无法创建子对象。
 3. 初始化最外层的 Model, 并调用其 setModel 方法。
 */
class JsonModel: NSObject {
    
    
    // MARK: 子类类型键值对
    
    /// 子类类型键值对，例如 result:
    static var types: [String: JsonModel] = [:]
    
    
    required override init() {
        super.init()
    }
    
    /// 将 Json 数据存入对象
    func setModel(data: NSData?) {
        if let obj = data {
            if let json = try? NSJSONSerialization.JSONObjectWithData(obj, options: NSJSONReadingOptions.AllowFragments) {
                jsonKeySetValue("", key: "", json: json)
            }
        }
    }
    
    // MARK: 设置不存在 Key 时不退出程序
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        print("\(self) -> key: \(key) is Undefined; value: \(value);")
    }
    
    /// 对象存入
    private func jsonKeySetValue(path: String, key: String, json: AnyObject) {
        if let dic = json as? [String: AnyObject] {
            for (k, v) in dic {
                if key.isEmpty {
                    jsonKeySetValue("\(k)", key: "\(k)", json: v)
                } else {
                    jsonKeySetValue("\(path).\(k)", key: "\(k)", json: v)
                }
            }
        } else if let arr = json as? [AnyObject] {
            var typeKey = key
            if key.isEmpty {
                typeKey = "ArrayTypeKey"
            }
            if let type = JsonModel.types[typeKey] {
                var value = [JsonModel]()
                for v in arr {
                    let sub = type.dynamicType.init()
                    sub.jsonKeySetValue("", key: "", json: v)
                    value.append(sub)
                }
                setValue(value, forKeyPath: path)
            }
        } else {
            setValue(json, forKeyPath: path)
        }
    }
}
