//
//  Wating.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/27.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

class Wating: UIView {

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    private func load() {
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 0
        
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: bounds.width/2, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        shape.frame = bounds
        shape.path = path.CGPath
        shape.lineCap = kCALineCapRound
        shape.lineWidth = lineWidth
        shape.strokeColor = color.CGColor
        shape.fillColor = UIColor.clearColor().CGColor
        shape.strokeStart = 0.9
        shape.shadowOpacity = shadowOpacity
        shape.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        shape.shadowRadius = shadowRadius
        layer.addSublayer(shape)
        
        addSubview(label)
        deployLabel()
    }
    
    // MARK: - Override
    
    override var frame: CGRect {
        didSet {
            shape.frame = bounds
            shape.path = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: bounds.width/2, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true).CGPath
            shape.displayIfNeeded()
            deployLabel()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            shape.frame = bounds
            shape.path = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: bounds.width/2, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true).CGPath
            shape.displayIfNeeded()
            deployLabel()
        }
    }
    
    // MARK: - Layer
    
    private let shape: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable var color: UIColor = UIColor.blueColor() {
        didSet {
            shape.strokeColor = color.CGColor
        }
    }
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet {
            shape.lineWidth = lineWidth
        }
    }
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            shape.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset: CGPoint = CGPointZero {
        didSet {
            shape.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 1 {
        didSet {
            shape.shadowRadius = shadowRadius
        }
    }
    
    // MARK: - Animation
    
    private var animating: Bool = false
    
    func start() {
        if !animating {
            animating = true
            showAnimation(animating)
            scaleAnimation1()
            rototeAnimation()
        }
    }
    
    func end() {
        if animating {
            animating = false
            showAnimation(false)
        }
    }
    
    private func showAnimation(show: Bool) {
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = show ? 1 : 0
            }) { (finish) in
                if !show {
                    self.shape.removeAllAnimations()
                }
        }
    }
    
    private func scaleAnimation1() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        CATransaction.setCompletionBlock { 
            self.scaleAnimation2()
        }
        shape.strokeStart = 0.6
        CATransaction.commit()
    }
    
    private func scaleAnimation2() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setCompletionBlock {
            if self.animating {
                self.scaleAnimation1()
            }
        }
        shape.strokeStart = 0.9
        CATransaction.commit()
    }
    
    private func rototeAnimation() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.duration = 2
        rotate.fromValue = 0
        rotate.toValue = 2 * M_PI
        rotate.repeatCount = HUGE
        shape.addAnimation(rotate, forKey: nil)
    }
    
    // MARK: - Label
    
    var label = UILabel()
    
    func deployLabel() {
        label.sizeToFit()
        label.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    func setLabelText(text: String) {
        label.text = text
        deployLabel()
    }
    
}
