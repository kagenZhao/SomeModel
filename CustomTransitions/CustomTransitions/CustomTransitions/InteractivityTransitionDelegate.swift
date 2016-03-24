//
//  InteractivityTransitionDelegate.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class InteractivityTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var gestureRecognizer: UIScreenEdgePanGestureRecognizer?
    var targetEdge: UIRectEdge = .None
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return InteractivityTransitionAnimator(targetEdge:targetEdge)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return InteractivityTransitionAnimator(targetEdge:targetEdge)
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let gestureRecognizer = self.gestureRecognizer {
            return TransitionInteractionController(gestureRecognizer: gestureRecognizer, edgeForDragging: targetEdge)
        }
        return nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let gestureRecognizer = self.gestureRecognizer {
            return TransitionInteractionController(gestureRecognizer: gestureRecognizer, edgeForDragging: targetEdge)
        }
        return nil
    }

}
