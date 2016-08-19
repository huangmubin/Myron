//
//  AutoLayout.swift
//  
//
//  Created by 黄穆斌 on 16/8/19.
//
//

import UIKit

// MARK: - AutoLayout 封装
class AutoLayout {

    // MARK: Views
    
    /// 父视图
    weak var view: UIView!
    /// 添加约束的视图
    weak var first: UIView!
    /// 作为对比的视图
    weak var second: UIView?
    
    // MARK: 初始化，设置对象
    
    /// 设置 superview first second
    init(_ view: UIView, _ first: UIView, _ second: UIView? = nil) {
        self.view = view
        self.first = first
        self.first.translatesAutoresizingMaskIntoConstraints = false
        if let second = second {
            self.second = second
            self.second?.translatesAutoresizingMaskIntoConstraints = false
        } else {
            self.second = view
        }
    }
    
    /// 设置 itemview
    func first(view: UIView) -> AutoLayout {
        self.first = view
        return self
    }
    
    /// 设置 toitemview
    func second(view: UIView?) -> AutoLayout {
        self.second = view
        return self
    }
    
    /// 设置 views
    func views(first: UIView, _ second: UIView?) -> AutoLayout {
        self.first = first
        self.second = second
        return self
    }
    
    // MARK: Constraints
    
    /// 约束存放数组
    var _constrants: [NSLayoutConstraint] = []
    
    /// 清理约束
    func clearConstrants() -> AutoLayout {
        _constrants.removeAll(keepCapacity: true)
        return self
    }
    
    /// 获取约束
    func constrants(block: ([NSLayoutConstraint]) -> Void) -> AutoLayout {
        block(_constrants)
        return self
    }
}

// MARK: - 全自定义方法
extension AutoLayout {

    /// 自定义方法 -> 将 constraint 添加到 _constrants 中，并返回 AutoLayout
    func add(FEdge: NSLayoutAttribute, SEdge: NSLayoutAttribute, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .Equal) -> AutoLayout {
        let constraint = NSLayoutConstraint(item: first, attribute: FEdge, relatedBy: related, toItem: second, attribute: SEdge, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        _constrants.append(constraint)
        view.addConstraint(constraint)
        return self
    }
    
    /// 全自定义方法 -> 返回设置的约束
    func layout(FEdge: NSLayoutAttribute, SEdge: NSLayoutAttribute, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .Equal) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: first, attribute: FEdge, relatedBy: related, toItem: second, attribute: SEdge, multiplier: multiplier, constant: constant)
        constraint.priority = priority
        constraint.firstItem
        constraint.secondItem
        view.addConstraint(constraint)
        return constraint
    }
}

// MARK: - 单边方法
extension AutoLayout {
    
    /// Top <-> Top
    func top(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: related, toItem: second, attribute: .Top, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// Bottom <-> Bottom
    func bottom(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: related, toItem: second, attribute: .Bottom, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// Leading <-> Leading
    func leading(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: related, toItem: second, attribute: .Leading, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// Trailing <-> Trailing
    func trailing(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: related, toItem: second, attribute: .Trailing, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// CenterX <-> CenterX
    func centerX(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .CenterX, relatedBy: related, toItem: second, attribute: .CenterX, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// CenterY <-> CenterY
    func centerY(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .CenterY, relatedBy: related, toItem: second, attribute: .CenterY, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    
    /// Width <-> Width
    func width(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Width, relatedBy: related, toItem: second, attribute: .Width, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// Height <-> Height
    func height(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Height, relatedBy: related, toItem: second, attribute: .Height, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
}
