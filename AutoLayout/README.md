
# AutoLayout.swift

AutoLayout 封装库。

# Api

# 设计思路

## 来源

对苹果 NSLayoutConstraint 类进行封装。并提供链式编程方法，简洁调用代码。

```
NSLayoutConstraint
convenience init(item view1: AnyObject,
            attribute attr1: NSLayoutAttribute,
         relatedBy relation: NSLayoutRelation,
               toItem view2: AnyObject?,
            attribute attr2: NSLayoutAttribute,
      multiplier multiplier: CGFloat,
                 constant c: CGFloat)
```

## 注意要点：
* 除了自身宽高设置以外，layoutContraint 都需要添加到父视图当中。
* 所有添加 Autolayout 的视图都需要把 translatesAutoresizingMaskIntoConstraints 设置为 false.
* priority 优先度需要额外进行设置。
* multiplier 倍数，在第一次设置之后就无法进行更改。
* constant 差额，可进行后期变更。
* 计算公式：
```
view1.att1 relation view2.attr2 * multiplier + constant
或者
view1.att1 (==, >=, <=) view2.attr2 * mulitiplier + constant
```

## 设计原则

* 调用模式为链式调用，可一次性添加多个约束。
* 函数调用使用默认值参数，方便使用时减少常用参数的重复设置。
* 调用之后可获取 layoutContraint, 作为后期动画变动使用。

# 更新记录

* 2016-08-19 创建。