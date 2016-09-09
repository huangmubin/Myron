//
//  AutoLayout.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/9/9.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - AutoLayout
let AutoLayout = AutoLayoutClass()
class AutoLayoutClass {
    
    // MARK: Views
    
    weak var view: UIView!
    var layouts: [NSLayoutConstraint] = []
    
    subscript(view: UIView) -> AutoLayoutClass {
        self.view = view
        return self
    }
    
    // MARK: - Function
    
    func view(view: UIView) {
        self.view = view
    }
    
    func end() {
        for layout in layouts {
            view.addConstraint(layout)
        }
    }
    
    func layouts(block: (Void) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            block()
            self?.addConstraint()
        }
    }
    
    func addConstraint() {
        for layout in layouts {
            view.addConstraint(layout)
        }
    }
}

// MARK: - Extension

extension UIView {
    
    var width: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Width)
    }
    var height: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Height)
    }
    var leading: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Leading)
    }
    var trailing: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Trailing)
    }
    var top: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Top)
    }
    var bottom: AutoLayoutView {
        return AutoLayoutView(view: self, attribute: NSLayoutAttribute.Bottom)
    }
    
}

// MARK: - AutoLayoutView

class AutoLayoutView {
    
    weak var view: UIView!
    var attribute: NSLayoutAttribute
    
    init(view: UIView, attribute: NSLayoutAttribute) {
        self.view = view
        self.attribute = attribute
    }
    
    var multiplier: CGFloat = 1
    var constant: CGFloat = 0
    var priority: Float = 1000
    
}

// MARK: - Operation

// MARK: Create Layout

func ==(left: AutoLayoutView, right: AutoLayoutView) -> NSLayoutConstraint {
    left.view.translatesAutoresizingMaskIntoConstraints = false
    let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .Equal, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
    layout.priority = right.priority
    AutoLayout.layouts.append(layout)
    return layout
}

// MARK: Set Value

func *(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.multiplier = right
    return left
}
func /(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.multiplier = 1/right
    return left
}
func +(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.constant = right
    return left
}
func -(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.constant = -right
    return left
}
func |(left: AutoLayoutView, right: Float) -> AutoLayoutView {
    left.priority = right
    return left
}


/*
class AutoLayoutView {
    
    weak var view: UIView!
    var single: Bool = true
    lazy var attribute: NSLayoutAttribute! = nil
    var layout: NSLayoutConstraint!
    
    var multiplier: CGFloat = 1
    var constant: CGFloat = 0
    var priority: Float = 1000
    
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: - Property
    
    var width: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Width
        return self
    }
    var height: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Height
        return self
    }
    var leading: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Leading
        return self
    }
    var trailing: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Trailing
        return self
    }
    var top: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Top
        return self
    }
    var bottom: AutoLayoutView {
        self.attribute = NSLayoutAttribute.Bottom
        return self
    }
}


// MARK: - Operation

// MARK: Set

infix operator <|{ associativity none precedence 10 }
func <|(left: AutoLayoutView, right: AutoLayoutView) -> AutoLayoutView {
    left.view.addConstraint(right.layout)
    return right
}

// MARK: Create Layout

func ==(left: AutoLayoutView, right: AutoLayoutView) -> AutoLayoutView {
    left.view.translatesAutoresizingMaskIntoConstraints = false
    let layout = NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: .Equal, toItem: right.view, attribute: right.attribute, multiplier: right.multiplier, constant: right.constant)
    layout.priority = right.priority
    right.layout = layout
    return right
}

// MARK: Set Value

func *(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.multiplier = right
    return left
}
func /(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.multiplier = 1/right
    return left
}
func +(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.constant = right
    return left
}
func -(left: AutoLayoutView, right: CGFloat) -> AutoLayoutView {
    left.constant = -right
    return left
}
func |(left: AutoLayoutView, right: Float) -> AutoLayoutView {
    left.priority = right
    return left
}



*/