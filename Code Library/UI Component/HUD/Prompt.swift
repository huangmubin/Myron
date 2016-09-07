//
//  HUD.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/31.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

enum PromptType {
    case Success
    case Error
    case Text
    case Loading
}

// MARK: - Interface

extension Prompt {
    
    class func show(view: UIView, type: PromptType, text: String = "", time: Int = 0, canBeTouch: Bool = false) -> Prompt {
        dismiss(view)
        
        let prompt = Prompt()
        prompt.type = type
        prompt.label.text = text
        prompt.label.sizeToFit()
        prompt.deploy()
        
        if canBeTouch {
            prompt.button.hidden = true
        }
        
        prompt.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prompt)
        view.addConstraint(NSLayoutConstraint(item: prompt, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: prompt, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: prompt, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: prompt, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        prompt.layoutIfNeeded()
        
        
        if time > 0 {
            prompt.timer(time)
        }
        return Prompt()
    }
    
    class func dismiss(view: UIView) {
        for sub in view.subviews {
            if let pro = sub as? Prompt {
                pro.dismiss()
            }
        }
    }
    
}

/// A Prompt view, Like HUD.
class Prompt: UIView {
    
    // MARK: - Data
    
    /// Images for success and error.
    static var images: (Success: UIImage?, Error: UIImage?) = (UIImage(named: "Success"), UIImage(named: "Error"))
    
    
    
    /// Type
    private var type: PromptType = PromptType.Loading
    
    /// Text
    private var title: String = "Loading..."
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRectZero)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    private func load() {
        self.backgroundColor = UIColor.clearColor()
        
        //
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        
        //
        addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.layer.backgroundColor = UIColor.whiteColor().CGColor
        background.layer.cornerRadius = 8
        background.layer.shadowOffset = CGSizeZero
        background.layer.shadowOpacity = 0.5
        
        //
        addSubview(show)
        //show.backgroundColor = UIColor.blueColor()
        show.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: show, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        //addConstraint(NSLayoutConstraint(item: show, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -15))
        showHeight = NSLayoutConstraint(item: show, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30)
        addConstraint(showHeight)
        addConstraint(NSLayoutConstraint(item: show, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 30))
        
        //
        addSubview(label)
        label.numberOfLines = 0
        label.text = title
        label.textColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: show, attribute: .Bottom, multiplier: 1, constant: 8))
        addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 120))
        
        //
        addConstraint(NSLayoutConstraint(item: background, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: background, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: background, attribute: .Height, relatedBy: .Equal, toItem: background, attribute: .Width, multiplier: 1, constant: 0))
        let top = NSLayoutConstraint(item: background, attribute: .Top, relatedBy: .Equal, toItem: show, attribute: .Top, multiplier: 1, constant: -20)
        top.priority = 200
        addConstraint(top)
        addConstraint(NSLayoutConstraint(item: background, attribute: .Leading, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: label, attribute: .Leading, multiplier: 1, constant: -10))
        addConstraint(NSLayoutConstraint(item: background, attribute: .Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: label, attribute: .Bottom, multiplier: 1, constant: 10))
    }
    
    // MARK: - Views
    
    let background: UIView = UIView()
    let show: UIView = UIView()
    let label: UILabel = UILabel()
    let button: UIButton = UIButton()
    
    lazy var image: UIImageView = UIImageView()
    lazy var activity: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    // MARK: Layout
    
    private var showHeight: NSLayoutConstraint!
    
    // MARK: - Deploy
    
    func deploy() {
        switch type {
        case .Success:
            showHeight.constant = 30
            image.removeFromSuperview()
            show.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Top, relatedBy: .Equal, toItem: show, attribute: .Top, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Bottom, relatedBy: .Equal, toItem: show, attribute: .Bottom, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Leading, relatedBy: .Equal, toItem: show, attribute: .Leading, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Trailing, relatedBy: .Equal, toItem: show, attribute: .Trailing, multiplier: 1, constant: 0))
            
            image.image = Prompt.images.Success
        case .Error:
            showHeight.constant = 30
            image.removeFromSuperview()
            show.addSubview(image)
            image.translatesAutoresizingMaskIntoConstraints = false
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Top, relatedBy: .Equal, toItem: show, attribute: .Top, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Bottom, relatedBy: .Equal, toItem: show, attribute: .Bottom, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Leading, relatedBy: .Equal, toItem: show, attribute: .Leading, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: image, attribute: .Trailing, relatedBy: .Equal, toItem: show, attribute: .Trailing, multiplier: 1, constant: 0))
            
            image.image = Prompt.images.Error
        case .Text:
            showHeight.constant = 0
        case .Loading:
            showHeight.constant = 30
            show.addSubview(activity)
            activity.startAnimating()
            activity.translatesAutoresizingMaskIntoConstraints = false
            
            show.addConstraint(NSLayoutConstraint(item: activity, attribute: .CenterX, relatedBy: .Equal, toItem: show, attribute: .CenterX, multiplier: 1, constant: 0))
            show.addConstraint(NSLayoutConstraint(item: activity, attribute: .CenterY, relatedBy: .Equal, toItem: show, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        self.layoutIfNeeded()
    }
    
    func dismiss() {
        if let time = timerSource {
            dispatch_source_cancel(time)
        } else {
            self.removeFromSuperview()
        }
    }
    
    var timerSource: dispatch_source_t?
    func timer(time: Int) {
        var i = time
        timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dispatch_source_set_timer(timerSource!, dispatch_walltime(nil, 0), NSEC_PER_SEC, 0)
        dispatch_source_set_event_handler(timerSource!, { [weak self] in
            i -= 1
            if i < 0 {
                if let weakself = self {
                    dispatch_source_cancel(weakself.timerSource!)
                }
            }
        })
        dispatch_source_set_cancel_handler(timerSource!, { [weak self] in
            self?.removeFromSuperview()
        })
        dispatch_resume(timerSource!)
    }
}
