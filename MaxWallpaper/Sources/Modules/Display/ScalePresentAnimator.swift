//
//  ScalePresentAnimator.swift
//  MaxWallpaper
//
//  Created by elijah on 2019/3/19.
//  Copyright © 2019 elijah. All rights reserved.
//

import UIKit

class ScalePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresent: Bool
    var originFrame: CGRect
    
    override init() {
        isPresent = true
        originFrame = CGRect.zero
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let to: UIViewController? = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let from: UIViewController? = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        guard let toVC = to, let fromVC = from else {
            return
        }
        
        let toView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.to) ?? toVC.view
        let fromView: UIView = transitionContext.view(forKey: UITransitionContextViewKey.from) ?? fromVC.view
        var transView: UIView
        var endFrame: CGRect
        if (isPresent) {
            transView = toView
            transView.frame = originFrame
            endFrame = fromView.bounds
            transitionContext.containerView.addSubview(toView)
            JKLog("\(transView), from: \(originFrame), to: \(endFrame)")
        } else {
            transView = fromView
            endFrame = originFrame
//            transView.removeFromSuperview()
        }
        // 动效总时间; 延迟时间; 弹簧的值，0~1，越小弹性越大; 初始速度0~100
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 20, options: .allowUserInteraction, animations: {
                transView.frame = endFrame
        }) { (flag) in
            self.isPresent = false
            transitionContext.completeTransition(true)
        }
    }
}
