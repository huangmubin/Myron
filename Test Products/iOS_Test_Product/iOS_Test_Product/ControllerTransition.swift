//
//  ControllerTransition.swift
//  iOS_Test_Product
//
//  Created by 黄穆斌 on 16/8/25.
//  Copyright © 2016年 Myron. All rights reserved.
//

import UIKit

// MARK: Controller Transition Animation
class ControllerTransition: NSObject, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
    
    // MARK: Init
    static var transition = ControllerTransition()
    private override init() {
        super.init()
    }
    
    
    // MARK: Animation Data
    
    /// animation Time:  UIViewControllerAnimatedTransitioning transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval
    var duration: NSTimeInterval = 0
    
    /// Animation
    var animationBegin: ((from: UIViewController?, to: UIViewController?, container: UIView?) -> [String: AnyObject])? = nil
    var animationBlock: ((from: UIViewController?, to: UIViewController?, container: UIView?, infos: [String: AnyObject]) -> Void)? = nil
    var animationEnd: ((Bool) -> Void)? = nil
    
    
    // MARK: - Percent
    
    private var percentDrivenTransition: UIPercentDrivenInteractiveTransition?
    
    func percentStart() {
        percentDrivenTransition = UIPercentDrivenInteractiveTransition()
    }
    
    func percentUpdate(percent: CGFloat) {
        percentDrivenTransition?.updateInteractiveTransition(percent)
    }
    
    func percentFinish(finish: Bool) {
        if finish {
            percentDrivenTransition?.finishInteractiveTransition()
        } else {
            percentDrivenTransition?.cancelInteractiveTransition()
        }
        self.percentDrivenTransition = nil
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let container = transitionContext.containerView()
        let infos = animationBegin?(from: fromController, to: toController, container: container)
        UIView.animateWithDuration(transitionDuration(transitionContext)) {
            self.animationBlock?(from: fromController, to: toController, container: container, infos: infos ?? [:])
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        animationEnd?(transitionCompleted)
        animationBegin = nil
        animationBlock = nil
        animationEnd   = nil
    }
    
    // MARK: - UINavigationControllerDelegate
    
    /*
    optional public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
    @available(iOS 2.0, *)
    optional public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool)
     
    @available(iOS 7.0, *)
    optional public func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation
 
    @available(iOS 7.0, *)
    optional public func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask
    
    */
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return ControllerTransition.transition.percentDrivenTransition
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ControllerTransition.transition
    }
}
