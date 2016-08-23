import Foundation

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
