//
//  Carousel.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/24.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Carousel Model

class CarouselModel {
    var image: UIImage?
    var name: String = ""
}

// MARK: - Carousel
class Carousel: UIView {
    
    // MARK: Datas
    
    /// Carousel Data Models
    var models = [CarouselModel]()
    /// Carousel Index
    var index = 0
    /// Rolling direction is horizontal or vertical, default horizontal.
    var direction = true {
        didSet {
            updateLayout(false)
            layoutIfNeeded()
        }
    }
    
    // MARK: Methods
    
    /// Reload the models images.
    func reload() {
        index = 0
        
        leftView.image = nil
        
        if models.count > 0 {
            centerView.image = models[0].image
        }
        if models.count > 1 {
            rightView.image = models[1].image
        }
        
        moveLayout.constant = 0
        heightLayout.constant = 0
        widthLayout.constant = 0
        layoutIfNeeded()
    }
    
    // MARK: Views
    
    /// Left Subview
    private var leftView: UIImageView = UIImageView()
    /// Center Subview
    private var centerView: UIImageView = UIImageView()
    /// Right Subview
    private var rightView: UIImageView = UIImageView()
    
    // MARK: Gestures
    
    /// Pan Gesture
    private var pan: UIPanGestureRecognizer!
    /// Pinch Gesture
    private var pinch: UIPinchGestureRecognizer!
    
    // MARK: Layouts
    
    /// Layout
    private var moveLayout: NSLayoutConstraint!
    
    private var centerLayout: NSLayoutConstraint!
    private var leftCenterLayout: NSLayoutConstraint!
    private var leftSideLayout: NSLayoutConstraint!
    private var rightCenterLayout: NSLayoutConstraint!
    private var rightSideLayout: NSLayoutConstraint!
    
    private var heightLayout: NSLayoutConstraint!
    private var widthLayout: NSLayoutConstraint!
    private var rheightLayout: NSLayoutConstraint!
    private var rwidthLayout: NSLayoutConstraint!
    private var lheightLayout: NSLayoutConstraint!
    private var lwidthLayout: NSLayoutConstraint!
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRectZero)
        load()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    /// Init the subviews.
    private func load() {
        
        // Image Views
        func deployView(view: UIImageView) {
            view.contentMode = UIViewContentMode.ScaleAspectFit
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            let height = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
            let width = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0)
            self.addConstraint(height)
            self.addConstraint(width)
            if view === centerView {
                heightLayout = height
                widthLayout = width
            }
            if view === leftView {
                lheightLayout = height
                lwidthLayout = width
            }
            if view === rightView {
                rheightLayout = height
                rwidthLayout = width
            }
        }
        deployView(leftView)
        deployView(centerView)
        deployView(rightView)
        
        leftView.image = UIImage(named: "1")
        centerView.image = UIImage(named: "2")
        rightView.image = UIImage(named: "3")
        
        updateLayout(true)
        
        // Gesture
        pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction))
        addGestureRecognizer(pan)
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction))
        addGestureRecognizer(pinch)
        
    }
    
    /// Clear Layouts and add new layout according to the direction.
    private func updateLayout(load: Bool) {
        if !load {
            let layouts = [leftCenterLayout, leftSideLayout, rightCenterLayout, rightSideLayout, centerLayout, moveLayout]
            for layout in constraints {
                if layouts.contains({ $0 === layout }) {
                    removeConstraint(layout)
                }
            }
        }
        
        if direction {
            leftCenterLayout = NSLayoutConstraint(item: leftView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            leftSideLayout = NSLayoutConstraint(item: leftView, attribute: .Trailing, relatedBy: .Equal, toItem: centerView, attribute: .Leading, multiplier: 1, constant: 0)
            rightCenterLayout = NSLayoutConstraint(item: rightView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            rightSideLayout = NSLayoutConstraint(item: rightView, attribute: .Leading, relatedBy: .Equal, toItem: centerView, attribute: .Trailing, multiplier: 1, constant: 0)
            
            centerLayout = NSLayoutConstraint(item: centerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
            moveLayout = NSLayoutConstraint(item: centerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        } else {
            leftCenterLayout = NSLayoutConstraint(item: leftView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            leftSideLayout = NSLayoutConstraint(item: leftView, attribute: .Bottom, relatedBy: .Equal, toItem: centerView, attribute: .Top, multiplier: 1, constant: 0)
            rightCenterLayout = NSLayoutConstraint(item: rightView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            rightSideLayout = NSLayoutConstraint(item: rightView, attribute: .Top, relatedBy: .Equal, toItem: centerView, attribute: .Bottom, multiplier: 1, constant: 0)
            
            centerLayout = NSLayoutConstraint(item: centerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
            moveLayout = NSLayoutConstraint(item: centerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        }
        addConstraints([leftCenterLayout, leftSideLayout, rightCenterLayout, rightSideLayout, centerLayout, moveLayout])
    }
    
    /// Update the imageviews's image by models and index.
    private func updateImage() {
        if index < models.count {
            centerView.image = models[index].image
        } else {
            return
        }
        
        if index-1 >= 0 {
            leftView.image = models[index-1].image
        } else {
            leftView.image = nil
        }
        
        if index+1 < models.count {
            rightView.image = models[index+1].image
        } else {
            rightView.image = nil
        }
    }
    
    // MARK: - Gesture
    
    private var offset: CGFloat = 0
    @objc private func panGestureAction(sender: UIPanGestureRecognizer) {
        if direction {
            offset = sender.translationInView(self).x
        } else {
            offset = sender.translationInView(self).y
        }
        
        switch sender.state {
        case .Began, .Changed:
            if (index == 0 && offset >= 0) || (index == models.count-1 && offset <= 0) {
                offset *= 0.3
            }
            self.moveLayout.constant = offset
            self.layoutIfNeeded()
        default:
            var size: CGFloat
            if direction {
                size = bounds.width / 2 + widthLayout.constant
            } else {
                size = bounds.height / 2 + heightLayout.constant
            }
            
            // Restore
            // TODO: 想办法解决放大的情况下可以进行偏移的情况
            if (abs(offset) < size) {
//                UIView.animateWithDuration(0.5) {
//                    self.moveLayout.constant = 0
//                    self.layoutIfNeeded()
//                }
                return
            }
            
            if (index == 0 && offset >= 0) || (index == models.count-1 && offset <= 0) {
                UIView.animateWithDuration(0.5) {
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                }
                return
            }
            
            // -1
            if offset > size {
                index -= 1
                updateImage()
                moveLayout.constant = moveLayout.constant - size * 2
                rheightLayout.constant = heightLayout.constant
                rwidthLayout.constant  = widthLayout.constant
                heightLayout.constant  = 0
                widthLayout.constant   = 0
                layoutIfNeeded()
                UIView.animateWithDuration(0.5, animations: { 
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                }, completion: { (finish) in
                        self.rheightLayout.constant = 0
                        self.rwidthLayout.constant = 0
                        self.layoutIfNeeded()
                })
                return
            }
            
            // +1
            if offset < -size {
                index += 1
                updateImage()
                moveLayout.constant = size * 2 + moveLayout.constant
                lheightLayout.constant = heightLayout.constant
                lwidthLayout.constant  = widthLayout.constant
                heightLayout.constant  = 0
                widthLayout.constant   = 0
                layoutIfNeeded()
                UIView.animateWithDuration(0.5, animations: {
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                    }, completion: { (finish) in
                        self.lheightLayout.constant = 0
                        self.lwidthLayout.constant = 0
                        self.layoutIfNeeded()
                })
                return
            }
            
            // Other, if already have...
            UIView.animateWithDuration(0.5) {
                self.moveLayout.constant = 0
                self.layoutIfNeeded()
            }
        }
    }
    
    
    private var scale: CGSize = CGSizeZero
    @objc private func pinchGestureAction(sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .Began:
            scale = CGSize(width: widthLayout.constant, height: heightLayout.constant)
        case .Changed:
            let offset = CGSize(width: bounds.width * (sender.scale - 1), height: bounds.height * (sender.scale - 1))
            if offset.height + self.scale.height <= -bounds.height / 2 || offset.width + self.scale.width <= -bounds.width / 2 {
                return
            } else if offset.height + self.scale.height < 0 || offset.width + self.scale.width < 0 {
                var size: CGFloat
                if direction {
                    size = -(offset.width + self.scale.width) / 2
                } else {
                    size = -(offset.height + self.scale.height) / 2
                }
                leftSideLayout.constant = -size
                rightSideLayout.constant = size
            } else {
                leftSideLayout.constant = 0
                rightSideLayout.constant = 0
            }
            self.heightLayout.constant = offset.height + self.scale.height
            self.widthLayout.constant  = offset.width + self.scale.width
            self.layoutIfNeeded()
        default:
            let offset = CGSize(width: bounds.width * (sender.scale - 1), height: bounds.height * (sender.scale - 1))
            if offset.height + self.scale.height <= 0 {
                UIView.animateWithDuration(0.5) {
                    self.heightLayout.constant = 0
                    self.widthLayout.constant  = 0
                    self.leftSideLayout.constant = 0
                    self.rightSideLayout.constant = 0
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
