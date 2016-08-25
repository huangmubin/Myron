//
//  ViewController.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/19.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var carousel: Carousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carousel = Carousel(frame: view.bounds)
        carousel.backgroundColor = UIColor.redColor()
        view.addSubview(carousel)
        
        for i in 1 ..< 7 {
            let model = CarouselModel()
            model.image = UIImage(named: "\(i)")
            model.name = "\(i)"
            carousel.models.append(model)
        }
        
        carousel.reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func lefitAction(sender: UIBarButtonItem) {
        carousel.direction = !carousel.direction
    }

    @IBAction func rightAction(sender: UIBarButtonItem) {
        carousel.remove()
    }
    
}

