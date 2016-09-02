//
//  ViewController.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/19.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var move: UIView = UIView(frame: CGRect(x: 50, y: 50, width: 60, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = ControllerTransition.transition
        move.backgroundColor = UIColor.redColor()
        view.addSubview(move)
    }
    
    @IBOutlet weak var wating: Wating!

    @IBAction func lefitAction(sender: UIBarButtonItem) {
        //wating.start()
        Prompt.dismiss(view)
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        //wating.end()
        Prompt.show(view, type: PromptType.Loading, text: "Sueeeesdfsafdasfasdfasdfasdfas", time: 0)
    }
    
    
    @IBAction func action(sender: UIButton) {
        //wating.label.text = "OK"
    }
    
    @IBAction func slider(sender: UISlider) {
        //wating.frame = CGRect(x: 0, y: 100, width: view.bounds.width * CGFloat(sender.value), height: view.bounds.width * CGFloat(sender.value))
    }
}

class ViewController2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }
    
}