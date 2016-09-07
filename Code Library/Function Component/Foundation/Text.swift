import Foundation

// MARK: - Extension String

extension String {
    
    // MARK: 从文档中获取字符串和保存成文档
    
    /// 文件操作: 把路径读取成字符串
    func read() -> String? {
        if let data = NSData(contentsOfFile: self) {
            if let text = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                return text
            }
        }
        return nil
    }
    
    /// 文件操作: 把字符串保存成文档
    func save(path: String) -> Bool {
        if let data = dataUsingEncoding(NSUTF8StringEncoding) {
            return data.writeToFile(path, atomically: true)
        } else {
            return false
        }
    }
    
    // MARK: 字符截取
    
    /// 根据范围获取字符串
    func sub(start: Int, end: Int) -> String {
        return substringWithRange(startIndex.advancedBy(start) ..< startIndex.advancedBy(end))
    }
    
    /// 根据范围替代字符串
    mutating func replace(start: Int, end: Int, text: String) {
        replaceRange(startIndex.advancedBy(start) ..< startIndex.advancedBy(end), with: text)
    }
    
    // MARK: 正则表达式
    
    /// 正则表达式: 查询是否符合规则
    func regex(pattern: String) -> Bool {
        if let regular = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
            let result = regular.numberOfMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            return result > 0
        }
        return false
    }
    
    /// 正则表达式: 查询第一个符合条件的字符串范围
    func regex1(pattern: String) -> (start: Int, end: Int)? {
        if let regular = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
            let result = regular.rangeOfFirstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            if result.length > 0 {
                return (result.location, result.location + result.length)
            }
        }
        return nil
    }
    
    /// 正则表达式: 返回所有符合规则的范围
    func regex2(pattern: String) -> [(start: Int, end: Int)] {
        var ranges = [(start: Int, end: Int)]()
        if let regular = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive) {
            let result = regular.matchesInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, characters.count))
            for range in result {
                ranges.append((range.range.location, range.range.location + range.range.length))
            }
        }
        return ranges
    }
    
}