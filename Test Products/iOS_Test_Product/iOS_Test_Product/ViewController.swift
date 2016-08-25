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

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        
        sub.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        sub.backgroundColor = UIColor.brownColor()
        view.addSubview(sub)
    }

    let sub = UIView()
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.Push {
            return nil
        } else {
            return nil
        }
    }
    
    @IBAction func lefitAction(sender: UIBarButtonItem) {
        
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        
    }
    
    var begin: ((view: UIView) -> Void)? = {
        $0.frame = CGRect(x: 100, y: 200, width: 100, height: 100)
    }
    var end: ((Bool) -> Void)? = {
        print("end = \($0)")
    }
    @IBAction func action(sender: UIButton) {
        //self.performSegueWithIdentifier("Segue", sender: nil)
        UIView.animateWithDuration(10, animations: { 
            self.begin?(view: self.sub)
            }, completion: end)
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