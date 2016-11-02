//
//  TransitionInteractionController.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class TransitionInteractionController: UIPercentDrivenInteractiveTransition {
    var transitionContext: UIViewControllerContextTransitioning? = nil
    var gestureRecognizer: UIScreenEdgePanGestureRecognizer
    var edge: UIRectEdge
    
    init(gestureRecognizer: UIScreenEdgePanGestureRecognizer, edgeForDragging edge: UIRectEdge) {
        assert(edge == .top || edge == .bottom || edge == .left || edge == .right,
               "edgeForDragging must be one of UIRectEdgeTop, UIRectEdgeBottom, UIRectEdgeLeft, or UIRectEdgeRight.")
        self.gestureRecognizer = gestureRecognizer
        self.edge = edge
        
        super.init()
        self.gestureRecognizer.addTarget(self, action: #selector(gestureRecognizeDidUpdate(_:)))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    /**
     用于根据计算动画完成的百分比
     
     :param: gesture 当前的滑动手势，通过这个手势获取滑动的位移
     
     :returns: 返回动画完成的百分比
     */
    private func percentForGesture(gesture: UIScreenEdgePanGestureRecognizer) -> CGFloat {
        let transitionContainerView = transitionContext?.containerView
        let locationInSourceView = gesture.location(in: transitionContainerView)
        
        let width = transitionContainerView?.bounds.width
        let height = transitionContainerView?.bounds.height
        
        switch self.edge {
        case UIRectEdge.right: return (width! - locationInSourceView.x) / width!
        case UIRectEdge.left: return locationInSourceView.x / width!
        case UIRectEdge.bottom: return (height! - locationInSourceView.y) / height!
        case UIRectEdge.top: return locationInSourceView.y / height!
        default: return 0
        }
    }
    
    /// 当手势有滑动时触发这个函数
    func gestureRecognizeDidUpdate(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began: break
        case .changed: self.update(self.percentForGesture(gesture: gestureRecognizer))  //手势滑动，更新百分比
        case .ended:    // 滑动结束，判断是否超过一半，如果是则完成剩下的动画，否则取消动画
            if self.percentForGesture(gesture: gestureRecognizer) >= 0.3 {
                self.finish()
            }
            else {
                self.cancel()
            }
        default: self.cancel()
        }
    }
}
