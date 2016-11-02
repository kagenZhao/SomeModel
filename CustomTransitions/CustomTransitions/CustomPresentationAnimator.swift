//
//  CustomPresentationAnimator.swift
//  CustomTransitions
//
//  Created by zhaoguoqing on 16/3/27.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class CustomPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let isAnimated = transitionContext?.isAnimated {
            return isAnimated ? 0.35 : 0
        }
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containerView = transitionContext.containerView
        
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        let isPresenting = (toViewController?.presentingViewController == fromViewController)
        
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController!)
        var toViewInitialFrame = transitionContext.initialFrame(for: toViewController!)
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController!)
        
        if toView != nil {
            containerView.addSubview(toView!)
        }
        
        if isPresenting {
            toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
            toViewInitialFrame.size = toViewFinalFrame.size
            toView?.frame = toViewInitialFrame
        } else {
            fromViewFinalFrame = fromView!.frame.offsetBy(dx: 0, dy: fromView!.frame.height)
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: transitionDuration, animations: {
            if isPresenting {
                toView?.frame = toViewFinalFrame
            }
            else {
                fromView?.frame = fromViewFinalFrame
            }
            
        }) { (finished: Bool) -> Void in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}
