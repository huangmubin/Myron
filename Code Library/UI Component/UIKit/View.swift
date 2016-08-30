//
//  View.swift
//  
//
//  Created by 黄穆斌 on 16/7/31.
//
//

import UIKit

class View: UIView {
    
    // MARK: - Values
    
    /// 视图圆角: x 左上角, y 右上角, h 右下角, w 左下角
    @IBInspectable var cornerRadius: CGRect = CGRectZero { didSet { draw() } }
    /// 阴影透明度
    @IBInspectable var shadowOpacity: Float = 0 { didSet { draw() } }
    /// 阴影扩展
    @IBInspectable var shadowRadius: CGFloat = 0 { didSet { draw() } }
    /// 阴影偏移
    @IBInspectable var shadowOffset: CGPoint = CGPointZero { didSet { draw() } }
    /// 视图颜色
    @IBInspectable var color: UIColor = UIColor.blueColor() {
        didSet {
            backLayer.backgroundColor = color.CGColor
            backgroundColor = UIColor.clearColor()
            draw()
        }
    }
    
    // MARK: - Override
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != UIColor.clearColor() && backgroundColor != nil {
                color = backgroundColor!
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            backLayer.path = roundedPath(bounds.size, a: cornerRadius.origin.x, b: cornerRadius.origin.y, c: cornerRadius.height, d: cornerRadius.width).CGPath
            layer.displayIfNeeded()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            backLayer.path = roundedPath(bounds.size, a: cornerRadius.origin.x, b: cornerRadius.origin.y, c: cornerRadius.height, d: cornerRadius.width).CGPath
            layer.displayIfNeeded()
        }
    }
    
    // MARK: - Draw
    
    private var backLayer: CAShapeLayer = CAShapeLayer()
    
    func draw() {
        backgroundColor = UIColor.clearColor()
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = CGSize(width: shadowOffset.x, height: shadowOffset.y)
        layer.masksToBounds = clipsToBounds
        layer.backgroundColor = UIColor.clearColor().CGColor
        
        backLayer.path = roundedPath(bounds.size, a: cornerRadius.origin.x, b: cornerRadius.origin.y, c: cornerRadius.height, d: cornerRadius.width).CGPath
        backLayer.fillColor = color.CGColor
        backLayer.strokeColor = UIColor.clearColor().CGColor
        layer.insertSublayer(backLayer, atIndex: 0)
    }
    
    // MARK: - Drawer
    
    func roundedPath(size: CGSize, a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: a))
        path.addArcWithCenter(CGPoint(x: a, y: a), radius: a, startAngle: CGFloat(M_PI), endAngle: CGFloat(M_PI_2) * 3, clockwise: true)
        path.addLineToPoint(CGPoint(x: size.width - b, y: 0))
        path.addArcWithCenter(CGPoint(x: size.width - b, y: b), radius: b, startAngle: CGFloat(M_PI_2) * 3, endAngle: CGFloat(M_PI_2) * 4, clockwise: true)
        path.addLineToPoint(CGPoint(x: size.width, y: size.height - c))
        path.addArcWithCenter(CGPoint(x: size.width - c, y: size.height - c), radius: c, startAngle: 0, endAngle: CGFloat(M_PI_2), clockwise: true)
        path.addLineToPoint(CGPoint(x: d, y: size.height))
        path.addArcWithCenter(CGPoint(x: d, y: size.height - d), radius: d, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI), clockwise: true)
        path.closePath()
        return path
    }

}
