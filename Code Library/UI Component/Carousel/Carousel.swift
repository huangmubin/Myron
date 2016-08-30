//
//  Carousel.swift
//  
//
//  Created by 黄穆斌 on 16/8/24.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: - Protocol

@objc protocol CarouselDelegate: NSObjectProtocol {
    
    optional func carouselBeginPan(carousel: Carousel, index: Int)
    optional func carouselIndexChanged(carousel: Carousel, index: Int)
    optional func carouselTapImage(carousel: Carousel, index: Int)
    optional func carouselPinchAction(carousel: Carousel, pan: UIPinchGestureRecognizer, size: CGFloat)
    
}

protocol CarouselModelDelegate: NSObjectProtocol {
    func carouselModelImageDownload(model: CarouselModel, data: NSData)
    func carouselModelDefaultImage(model: CarouselModel) -> UIImage?
}

// MARK: - Carousel Model

class CarouselModel {
    var name: String = ""
    var delegate: CarouselModelDelegate?
    
    private var _image: UIImage?
    var image: UIImage? {
        set {
            _image = newValue
        }
        get {
            if _image == nil {
                if data != nil {
                    _image = UIImage(data: data!)
                } else if required != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        let session = NSURLSession.sharedSession()
                        session.dataTaskWithRequest(self.required!, completionHandler: { (data, response, error) in
                            if let data = data {
                                if let image = UIImage(data: data) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self._image = image
                                        self.delegate?.carouselModelImageDownload(self, data: data)
                                    }
                                }
                            }
                        })
                    }
                } else if url != nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                        if let loadurl = NSURL(string: self.url!) {
                            if let data = NSData(contentsOfURL: loadurl) {
                                if let image = UIImage(data: data) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self._image = image
                                        self.delegate?.carouselModelImageDownload(self, data: data)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return _image ?? delegate?.carouselModelDefaultImage(self)
        }
    }
    
    var data: NSData?
    var required: NSURLRequest?
    var url: String?
    
}

// MARK: - Carousel
class Carousel: UIView {
    
    // MARK: Datas
    
    /// Carousel Data Models
    var models = [CarouselModel]() {
        didSet {
            pageControl.numberOfPages = models.count
        }
    }
    /// Carousel Index
    var index = 0 {
        didSet {
            updateImage()
            pageControl.currentPage = index
        }
    }
    /// Rolling direction is horizontal or vertical, default horizontal.
    var direction = true {
        didSet {
            updateLayout(false)
            layoutIfNeeded()
        }
    }
    /// Frame
    var centerFrame: CGRect {
        return centerView.frame
    }
    /// Delegate
    var delegate: CarouselDelegate?
    
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
    
    /// Delete
    func remove() {
        guard self.models.count > 0 else { return }
        UIView.animateWithDuration(0.3, animations: { 
            self.heightLayout.constant = -self.bounds.height
            self.widthLayout.constant  = -self.bounds.width
            self.moveLayout.constant   = self.index == self.models.count-1 ? self.bounds.width/2 : -self.bounds.width/2
            self.layoutIfNeeded()
            }) { (finish) in
                self.heightLayout.constant = 0
                self.widthLayout.constant  = 0
                self.moveLayout.constant   = 0
                if self.index == self.models.count-1 {
                    self.models.removeAtIndex(self.index)
                    self.index -= 1
                } else {
                    self.models.removeAtIndex(self.index)
                    self.updateImage()
                }
                self.layoutIfNeeded()
        }
    }
    
    // MARK: Views
    
    /// Left Subview
    private var leftView: UIImageView = UIImageView()
    /// Center Subview
    private var centerView: UIImageView = UIImageView()
    /// Right Subview
    private var rightView: UIImageView = UIImageView()
    /// Page Control
    var pageControl: UIPageControl = UIPageControl()
    /// Title
    var title: UILabel = UILabel()
    
    // MARK: Gestures
    
    /// Pan Gesture
    private var pan: UIPanGestureRecognizer!
    /// Pinch Gesture
    private var pinch: UIPinchGestureRecognizer!
    /// Tap Gesture
    private var tap: UITapGestureRecognizer!
    /// Tap Gesture
    private var doubleTap: UITapGestureRecognizer!
    
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
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureAction))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        tap.requireGestureRecognizerToFail(doubleTap)
        
        //
        pageControl.numberOfPages = models.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        let CenterX = NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let Bottom = NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 10)
        self.addConstraint(CenterX)
        self.addConstraint(Bottom)
        
        //
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: title, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10))
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
        if index >= 0 && index < models.count {
            centerView.image = models[index].image
            title.text = models[index].name
        } else {
            leftView.image   = nil
            centerView.image = nil
            rightView.image  = nil
            title.text = nil
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
    private var begin: CGFloat = 0
    private var size: CGFloat = 0
    @objc private func panGestureAction(sender: UIPanGestureRecognizer) {
        if direction {
            offset = sender.translationInView(self).x
        } else {
            offset = sender.translationInView(self).y
        }
        
        switch sender.state {
        case .Began:
            delegate?.carouselBeginPan?(self, index: index)
            begin = moveLayout.constant
            fallthrough
        case .Changed:
            offset += begin
            if direction {
                size = widthLayout.constant / 2
            } else {
                size = heightLayout.constant / 2
            }
            if index == 0 && offset >= size {
                offset = size + (offset - size) * 0.3
            }
            if index == models.count-1 && offset <= -size {
                offset = (offset + size) * 0.3 - size
            }
            self.moveLayout.constant = offset
            self.layoutIfNeeded()
        default:
            offset += begin
            var velocity: CGFloat
            if direction {
                size = (bounds.width + widthLayout.constant) / 2
                velocity = sender.velocityInView(self).x
            } else {
                size = (bounds.width + heightLayout.constant) / 2
                velocity = sender.velocityInView(self).y
            }
            
            // Restore
            if abs(velocity) < 500 {
                if (index == 0 && offset >= 0) || (index == models.count-1 && offset <= 0) || (abs(offset) < size) {
                    var constant: CGFloat
                    if direction {
                        constant = widthLayout.constant / 2
                    } else {
                        constant = heightLayout.constant / 2
                    }
                    
                    if abs(offset) > constant {
                        UIView.animateWithDuration(0.3) {
                            self.moveLayout.constant = self.offset > 0 ? constant : -constant
                            self.layoutIfNeeded()
                        }
                    }
                    return
                }
            }
            
            var layout: CGFloat
            if direction {
                layout = widthLayout.constant / 2
            } else {
                layout = heightLayout.constant / 2
            }
            
            // -1
            if (offset > size || velocity > 500) && index > 0 {
                index -= 1
                moveLayout.constant = moveLayout.constant + layout - size * 2
                rheightLayout.constant = heightLayout.constant
                rwidthLayout.constant  = widthLayout.constant
                heightLayout.constant  = 0
                widthLayout.constant   = 0
                layoutIfNeeded()
                UIView.animateWithDuration(0.3, animations: {
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                }, completion: { (finish) in
                        self.delegate?.carouselIndexChanged?(self, index: self.index)
                        self.rheightLayout.constant = 0
                        self.rwidthLayout.constant = 0
                        self.layoutIfNeeded()
                })
                return
            }
            
            // +1
            if (offset < -size || velocity < -500) && index < models.count-1 {
                index += 1
                moveLayout.constant = size * 2 + moveLayout.constant - layout
                lheightLayout.constant = heightLayout.constant
                lwidthLayout.constant  = widthLayout.constant
                heightLayout.constant  = 0
                widthLayout.constant   = 0
                layoutIfNeeded()
                UIView.animateWithDuration(0.3, animations: {
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                    }, completion: { (finish) in
                        self.delegate?.carouselIndexChanged?(self, index: self.index)
                        self.lheightLayout.constant = 0
                        self.lwidthLayout.constant = 0
                        self.layoutIfNeeded()
                })
                return
            }
            
            // Other, if already have...
            UIView.animateWithDuration(0.3) {
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
            
            leftSideLayout.constant = -bounds.width * 5
            rightSideLayout.constant = bounds.width * 5
            
            delegate?.carouselPinchAction?(self, pan: sender, size: (self.heightLayout.constant + self.bounds.height) / self.bounds.height)
        case .Changed:
            let offset = CGSize(width: bounds.width * (sender.scale - 1), height: bounds.height * (sender.scale - 1))
            
            //
            if offset.height + self.scale.height <= -bounds.height * 0.8 || offset.width + self.scale.width <= -bounds.width * 0.8 {
                return
            }
            
            self.heightLayout.constant = offset.height + self.scale.height
            self.widthLayout.constant  = offset.width + self.scale.width
            
            
            self.layoutIfNeeded()
            
            delegate?.carouselPinchAction?(self, pan: sender, size: (self.heightLayout.constant + self.bounds.height) / self.bounds.height)
        default:
            delegate?.carouselPinchAction?(self, pan: sender, size: (self.heightLayout.constant + self.bounds.height) / self.bounds.height)
            
            let offset = CGSize(width: bounds.width * (sender.scale - 1), height: bounds.height * (sender.scale - 1))
            
            //
            if offset.height + self.scale.height <= 0 {
                UIView.animateWithDuration(0.3) {
                    self.heightLayout.constant = 0
                    self.widthLayout.constant  = 0
                    self.leftSideLayout.constant = 0
                    self.rightSideLayout.constant = 0
                    self.moveLayout.constant = 0
                    self.layoutIfNeeded()
                }
                return
            }
            
            //
            if direction {
                if moveLayout.constant > self.widthLayout.constant / 2 {
                    UIView.animateWithDuration(0.3, animations: {
                        self.moveLayout.constant = self.widthLayout.constant / 2
                        self.layoutIfNeeded()
                        }, completion: { (finish) in
                            self.leftSideLayout.constant = 0
                            self.rightSideLayout.constant = 0
                            self.layoutIfNeeded()
                    })
                    return
                } else if moveLayout.constant < -self.widthLayout.constant / 2 {
                    UIView.animateWithDuration(0.3, animations: {
                        self.moveLayout.constant = -self.widthLayout.constant / 2
                        self.layoutIfNeeded()
                        }, completion: { (finish) in
                            self.leftSideLayout.constant = 0
                            self.rightSideLayout.constant = 0
                            self.layoutIfNeeded()
                    })
                    return
                }
            } else {
                if moveLayout.constant > self.heightLayout.constant / 2 {
                    UIView.animateWithDuration(0.3, animations: {
                        self.moveLayout.constant = self.heightLayout.constant / 2
                        self.layoutIfNeeded()
                        }, completion: { (finish) in
                            self.leftSideLayout.constant = 0
                            self.rightSideLayout.constant = 0
                            self.layoutIfNeeded()
                    })
                    return
                } else if moveLayout.constant < -self.heightLayout.constant / 2 {
                    UIView.animateWithDuration(0.3, animations: {
                        self.moveLayout.constant = -self.heightLayout.constant / 2
                        self.layoutIfNeeded()
                        }, completion: { (finish) in
                            self.leftSideLayout.constant = 0
                            self.rightSideLayout.constant = 0
                            self.layoutIfNeeded()
                    })
                    return
                }
            }
            
            
            //
            self.leftSideLayout.constant = 0
            self.rightSideLayout.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        delegate?.carouselTapImage?(self, index: index)
    }
    
    @objc private func doubleTapGestureAction(sender: UITapGestureRecognizer) {
        if widthLayout.constant == 0 {
            UIView.animateWithDuration(0.3) {
                self.heightLayout.constant = self.bounds.height
                self.widthLayout.constant = self.bounds.width
                self.layoutIfNeeded()
            }
        } else {
            UIView.animateWithDuration(0.3) {
                self.heightLayout.constant = 0
                self.widthLayout.constant = 0
                self.moveLayout.constant = 0
                self.layoutIfNeeded()
            }
        }
    }
}
