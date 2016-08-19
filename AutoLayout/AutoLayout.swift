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

    // MARK: - 全自定义方法
    
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

    // MARK: - 宽高方法
    
    /// view <- Width
    func width(view: UIView, _ constant: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: related, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// view <- Height
    func height(view: UIView, _ constant: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: related, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// view: Width <-> Height
    func aspectRatio(view: UIView, _ constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: related, toItem: view, attribute: .Height, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// view: <- Width; <- Height
    func size(view: UIView, _ width: CGFloat, _ height: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layoutH = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        layoutH.priority = priority
        _constrants.append(layoutH)
        view.addConstraint(layoutH)
        
        let layoutW = NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height)
        layoutW.priority = priority
        _constrants.append(layoutW)
        view.addConstraint(layoutW)
        return self
    }
    
    // MARK: - 单边对比方法
    
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
    
    // MARK: - 距离
    
    /// Leading <-> Trailing
    func horizontal(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: related, toItem: second, attribute: .Trailing, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    /// Top <-> Bottom
    func vertical(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout {
        let layout = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: related, toItem: second, attribute: .Bottom, multiplier: multiplier, constant: constant)
        layout.priority = priority
        _constrants.append(layout)
        view.addConstraint(layout)
        return self
    }
    
    // MARK: - 双边对比方法
    
    // MARK: 常用
    
    /// 中心对齐 CenterX <-> CenterX; CenterY <-> CenterY
    func center(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .CenterX, relatedBy: .Equal, toItem: second, attribute: .CenterX, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .CenterY, relatedBy: .Equal, toItem: second, attribute: .CenterY, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 大小对齐 Width <-> Width; Height <-> Height
    func size(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Width, relatedBy: .Equal, toItem: second, attribute: .Width, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Height, relatedBy: .Equal, toItem: second, attribute: .Height, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 宽度对齐 Leading = Leading + constant; Trailing = Trailing - constant
    func leadingTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 高度对齐 Top = Top + constant; Bottom = Bottom - constant
    func topBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    // MARK: 角落
    
    /// 左上角 Leading = Leading + constant; Top = Top + constant
    func leadingTop(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 右上角 Top = Top + constant; Trailing = Trailing - constant
    func topTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 右下角 Trailing = Trailing - constant; Bottom = Bottom - constant
    func trailingBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 左下角 Bottom = Bottom - constant; Leading = Leading + constant
    func bottomLeading(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout1 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    // MARK: 三边对比方法
    
    /// 左方对齐 Bottom = Bottom - constant; Leading = Leading + constant; Top = Top + constant
    func bottomLeadingTop(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 上方对齐 Leading = Leading + constant; Top = Top + constant; Trailing = Trailing - constant
    func leadingTopTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 右方对齐 Top = Top + constant; Trailing = Trailing - constant; Bottom = Bottom - constant;
    func topTrailingBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    /// 下方对齐 Trailing = Trailing - constant; Bottom = Bottom - constant; Leading = Leading + constant
    func trailingBottomLeading(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        return self
    }
    
    // MARK: 四边对比方法
    
    /// 大小对齐 centerX = CetnerX; CenterY = CenterY; Width = Width * multiplier + constant; Height = Height * multiplier + constant;
    func centerSize(constant: CGFloat = 0, _ multiplier: CGFloat = 1, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .CenterX, relatedBy: .Equal, toItem: second, attribute: .CenterX, multiplier: 1, constant: 0)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .CenterY, relatedBy: .Equal, toItem: second, attribute: .CenterY, multiplier: 1, constant: 0)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Width, relatedBy: .Equal, toItem: second, attribute: .Width, multiplier: multiplier, constant: constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        
        let layout3 = NSLayoutConstraint(item: first, attribute: .Height, relatedBy: .Equal, toItem: second, attribute: .Height, multiplier: multiplier, constant: constant)
        layout2.priority = priority
        _constrants.append(layout3)
        view.addConstraint(layout3)
        return self
    }
    
    /// 四边对齐 Leading = Leading + constant; Top = Top + constant; Trailing = Trailing - constant; Bottom = Bottom - constant;
    func edge(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout {
        let layout0 = NSLayoutConstraint(item: first, attribute: .Leading, relatedBy: .Equal, toItem: second, attribute: .Leading, multiplier: 1, constant: constant)
        layout0.priority = priority
        _constrants.append(layout0)
        view.addConstraint(layout0)
        
        let layout1 = NSLayoutConstraint(item: first, attribute: .Top, relatedBy: .Equal, toItem: second, attribute: .Top, multiplier: 1, constant: constant)
        layout1.priority = priority
        _constrants.append(layout1)
        view.addConstraint(layout1)
        
        let layout2 = NSLayoutConstraint(item: first, attribute: .Trailing, relatedBy: .Equal, toItem: second, attribute: .Trailing, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout2)
        view.addConstraint(layout2)
        
        let layout3 = NSLayoutConstraint(item: first, attribute: .Bottom, relatedBy: .Equal, toItem: second, attribute: .Bottom, multiplier: 1, constant: -constant)
        layout2.priority = priority
        _constrants.append(layout3)
        view.addConstraint(layout3)
        return self
    }
}
