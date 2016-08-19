

# AutoLayout.swift

AutoLayout 封装库。

# Api

Api 设计规则
* 属性：必须使用的视图对象以及其设置方法，以及设置之后的 layout 对象。
* 方法
    * 全自定义方法：可完全自定义 Layout 的方法。
    * 单边，多边... 按边数定义的 Layout 方法，函数名称即为要设置对齐的边。
> 参数基本上都设置了默认值，并省略外部参数名。


* 属性
    * Views
        * weak var view: UIView! /// 父视图
        * weak var first: UIView! /// 添加约束的视图
        * weak var second: UIView? /// 作为对比的视图
    * 初始化，设置对象
        * init(_ view: UIView, _ first: UIView, _ second: UIView? = nil) 
        * func first(view: UIView) -> AutoLayout 
        * func second(view: UIView?) -> AutoLayout 
        * func views(first: UIView, _ second: UIView?) -> AutoLayout 
    * Constraints
        * var _constrants: [NSLayoutConstraint] /// 约束存放数组
        * func clearConstrants() -> AutoLayout
        * func constrants(block: ([NSLayoutConstraint]) -> Void) -> AutoLayout
* 全自定义方法
    * func add(FEdge: NSLayoutAttribute, SEdge: NSLayoutAttribute, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .Equal) -> AutoLayout
    * func layout(FEdge: NSLayoutAttribute, SEdge: NSLayoutAttribute, constant: CGFloat = 0, multiplier: CGFloat = 1, priority: Float = 1000, related: NSLayoutRelation = .Equal) -> NSLayoutConstraint
* 宽高方法
    * func width(view: UIView, _ constant: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout 
    * func height(view: UIView, _ constant: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout 
    * func aspectRatio(view: UIView, _ constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func size(view: UIView, _ width: CGFloat, _ height: CGFloat, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
* 单边对比方法
    * func top(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func bottom(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func leading(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func trailing(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func centerX(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func centerY(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func width(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func height(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
* 距离
    * func horizontal(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
    * func vertical(constant: CGFloat = 0, _ multiplier: CGFloat = 1, _ related: NSLayoutRelation = .Equal, priority: Float = 1000) -> AutoLayout
* 双边对比方法
    * 常用
        * func center(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func size(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func leadingTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func topBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
    * 角落
        * func leadingTop(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func topTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func trailingBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
        * func bottomLeading(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
* 三边对比方法
    * func bottomLeadingTop(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
    * func leadingTopTrailing(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
    * func topTrailingBottom(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
    * func trailingBottomLeading(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout
* 四边对比方法
    * func centerSize(constant: CGFloat = 0, _ multiplier: CGFloat = 1, priority: Float = 1000) -> AutoLayout
    * func edge(constant: CGFloat = 0, priority: Float = 1000) -> AutoLayout


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