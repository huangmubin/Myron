//
//  ViewController.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/19.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

class Transion: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    func animationEnded(transitionCompleted: Bool) {
        
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var wating: Wating!

    @IBAction func lefitAction(sender: UIBarButtonItem) {
        wating.start()
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        wating.end()
    }
    
    
    @IBAction func action(sender: UIButton) {
        wating.label.text = "OK"
    }
    
    @IBAction func slider(sender: UISlider) {
        wating.frame = CGRect(x: 0, y: 100, width: view.bounds.width * CGFloat(sender.value), height: view.bounds.width * CGFloat(sender.value))
    }
}

class ViewController2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }
    
}