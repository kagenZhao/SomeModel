//
//  ea0132738057  InteractivityTransitionAnimator.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class InteractivityTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let targetEdge: UIRectEdge
    
    init(targetEdge: UIRectEdge) {
        self.targetEdge = targetEdge
    }
    
    func  transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        var fromView = fromViewController?.view
        var toView = toViewController?.view
        
        if transitionContext.respondsToSelector(#selector(transitionContext.viewForKey(_:))) {
            fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
            toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        }
        
        /// isPresenting用于判断当前是present还是dismiss
        let isPresenting = (toViewController?.presentingViewController == fromViewController)
        let fromFrame = transitionContext.initialFrameForViewController(fromViewController!)
        let toFrame = transitionContext.finalFrameForViewController(toViewController!)
        
        /// offset结构体将用于计算toView的位置
        let offset: CGVector
        switch self.targetEdge {
        case UIRectEdge.Top: offset = CGVectorMake(0, 1)
        case UIRectEdge.Bottom: offset = CGVectorMake(0, -1)
        case UIRectEdge.Left: offset = CGVectorMake(1, 0)
        case UIRectEdge.Right: offset = CGVectorMake(-1, 0)
        default:fatalError("targetEdge must be one of UIRectEdgeTop, UIRectEdgeBottom, UIRectEdgeLeft, or UIRectEdgeRight.")
        }
        
        /// 根据当前是dismiss还是present，横屏还是竖屏，计算好toView的初始位置以及结束位置
        if isPresenting {
            fromView?.frame = fromFrame
            toView?.frame = CGRectOffset(toFrame, toFrame.size.width * offset.dx * -1,
                                         toFrame.size.height * offset.dy * -1)
            containerView?.addSubview(toView!)
        } else {
            fromView?.frame = fromFrame
            toView?.frame = toFrame
            containerView?.insertSubview(toView!, belowSubview: fromView!)
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: .CurveLinear, animations: {
            if isPresenting {
                toView?.frame = toFrame
            } else {
                fromView?.frame = CGRectOffset(fromFrame, fromFrame.size.width * offset.dx,
                    fromFrame.size.height * offset.dy)
            }
            }) { (finished) in
                let wasCanceled = transitionContext.transitionWasCancelled()
                if wasCanceled {toView?.removeFromSuperview()}
                transitionContext.completeTransition(!wasCanceled)
        }
    }
}
