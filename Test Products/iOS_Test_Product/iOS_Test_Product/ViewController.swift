//
//  ViewController.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/19.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    let v1 = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        v1.backgroundColor = UIColor.blueColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.addSubview(v1)
        AutoLayout.view(view)
        v1.top      == view.top + 100
        v1.bottom   == view.bottom - 100
        v1.leading  == view.leading + 100
        v1.trailing == view.trailing - 100
        AutoLayout.end()
        
//        AutoLayout[view].layouts {
//            self.v1.top == self.view.top + 100
//        }
//        AutoLayout(view: view, first: v1).layout { (first, second) in
//            second <| first.top == second.top + 100
//            second <| first.bottom == second.bottom - 100
//            second <| first.leading == second.leading + 100
//            second <| first.trailing == second.trailing - 100
//        }
    }
    
    @IBAction func lefitAction(sender: UIBarButtonItem) {
        
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func action(sender: UIButton) {
        
    }
    
    @IBAction func slider(sender: UISlider) {
        
    }
}

class ViewController2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }
    
}