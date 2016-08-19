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


