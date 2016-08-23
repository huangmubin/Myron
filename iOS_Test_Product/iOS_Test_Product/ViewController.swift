//
//  ViewController.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/19.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        //Explorer.shared.clearTmp()
//        for i in 0 ..< 13 {
//            let data = NSData(contentsOfFile: "/Users/Myron/Desktop/未命名文件夹/\(i).png")
//            Explorer.shared.save(data, name: "save_\(i).png", time: 1, folder: "Saves/", replace: false, infos: nil, cache: true)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Explorer.shared.clearCache()
    }

    @IBAction func lefitAction(sender: UIBarButtonItem) {
        //Explorer.shared.clearTmp()
        
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        // print("Cache Size = \(Explorer.shared.cache.size); Cache count = \(Explorer.shared.cache.queue.count);")
    }
    
    
    
    // MARK: - TableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if let data = Explorer.shared.read("Saves/", name: "save_\(indexPath.row).png") {
            let image = UIImage(data: data)
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = nil
        }
        return cell
    }
    
}

