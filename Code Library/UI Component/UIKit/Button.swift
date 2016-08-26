//
//  Button.swift
//  
//
//  Created by 黄穆斌 on 16/8/2.
//
//

import UIKit

class Button: UIButton {
    
    // MAKR: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    func deploy() {
        layer.shadowOffset = offset
        
        let select = self.selected
        self.selected = true
        self.selected = select
        
        let high = self.highlighted
        self.highlighted = true
        self.highlighted = high
    }
    
    // MARK: - Values
    
    // MAKR: Shadow
    
    /// 圆角角度
    @IBInspectable var corner: CGFloat = 0 {
        didSet {
            layer.cornerRadius = corner
        }
    }
    /// 阴影透明度
    @IBInspectable var opacity: Float = 0 {
        didSet {
            layer.shadowOpacity = opacity
        }
    }
    /// 阴影偏移
    @IBInspectable var offset: CGSize = CGSizeZero {
        didSet {
            layer.shadowOffset = offset
        }
    }
    /// 阴影距离
    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = radius
        }
    }
    
    // MARK: Back View
    
    /// 背景颜色
    var backColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.backgroundColor = selected ? tintColor.CGColor : backColor.CGColor
            backgroundColor = UIColor.clearColor()
        }
    }
    
    // MARK: Other
    
    /// 备注信息
    @IBInspectable var note: String = ""
    
    // MAKR: - Override
    
    // MARK: Status
    
    private var removeBackImageView: Bool = true
    override var selected: Bool {
        didSet {
            if removeBackImageView {
                for view in subviews {
                    if view is UIImageView && view !== imageView {
                        removeBackImageView = false
                        view.removeFromSuperview()
                    }
                }
            }
            layer.backgroundColor = selected ? tintColor.CGColor : backColor.CGColor
        }
    }
    
    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.2) {
                self.alpha = self.highlighted ? 0.3 : 1
            }
        }
    }
    
    
    // MARK: Color
    
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != UIColor.clearColor() {
                backColor = backgroundColor ?? UIColor.clearColor()
            }
        }
    }
    
}
