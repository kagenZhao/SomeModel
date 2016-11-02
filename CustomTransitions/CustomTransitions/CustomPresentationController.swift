//
//  CustomPresentationController.swift
//  CustomTransitions
//
//  Created by zhaoguoqing on 16/3/27.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate {
    
    let CORNER_RADIUS: CGFloat = 16
    var presentationWrappingView: UIView? = nil // 被添加动画效果的view，在presentedViewController的基础上添加了其他效果
    var dimmingView: UIView? = nil  // alpha为0.5的黑色蒙版
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    override var presentedView: UIView? {
        return self.presentationWrappingView
    }
}

// MARK: - 两组对应的方法，实现自定义presentation
extension CustomPresentationController {
    override func presentationTransitionWillBegin() {
        let presentationWrapperView = UIView(frame: self.frameOfPresentedViewInContainerView) // 添加阴影效果
        presentationWrapperView.layer.shadowOpacity = 0.44
        presentationWrapperView.layer.shadowRadius = 13
        presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6)
        /// 在重写父类的presentedView方法中，返回了self.presentationWrappingView，这个方法表示需要添加动画效果的视图
        /// 这里对self.presentationWrappingView赋值，从后面的代码可以看到这个视图处于视图层级的最上层
        self.presentationWrappingView = presentationWrapperView
        
        let presentationRoundedCornerView = UIView(frame: UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsetsMake(0, 0, -CORNER_RADIUS, 0))) // 添加圆角效果
        presentationRoundedCornerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS
        presentationRoundedCornerView.layer.masksToBounds = true
        
        let presentedViewControllerWrapperView = UIView(frame: UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, CORNER_RADIUS, 0)))
        presentedViewControllerWrapperView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        let presentedViewControllerView = super.presentedView
        presentedViewControllerView?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        presentedViewControllerView?.frame = presentedViewControllerWrapperView.bounds
        
        // 视图层级关系如下：
        // presentationWrapperView              <- 添加阴影效果
        //   |- presentationRoundedCornerView   <- 添加圆角效果 (masksToBounds)
        //        |- presentedViewControllerWrapperView
        //             |- presentedViewControllerView (presentedViewController.view)
        presentedViewControllerWrapperView.addSubview(presentedViewControllerView!)
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrapperView.addSubview(presentationRoundedCornerView)
        
        /// 深色的一层覆盖视图，让背景看上去比较暗
        let dimmingView = UIView(frame: (self.containerView?.bounds)!)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.isOpaque = false
        dimmingView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.dimmingViewTapped(_:))))
        self.dimmingView = dimmingView
        self.containerView?.addSubview(dimmingView)
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        self.dimmingView?.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.dimmingView?.alpha = 0.5
            }, completion: nil)
    }
    
    /// 如果present没有完成，把dimmingView和wrappingView都清空，这些临时视图用不到了
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    /// dismiss开始时，让dimmingView完全透明，这个动画和animator中的动画同时发生
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) -> Void in
            self.dimmingView?.alpha = 0
            }, completion: nil)
    }
    
    /// dismiss结束时，把dimmingView和wrappingView都清空，这些临时视图用不到了
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
}

// MARK: - UI事件处理
extension CustomPresentationController {
    func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Autolayout
extension CustomPresentationController {
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if let container = container as? UIViewController,
            container == self.presentedViewController{
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let container = container as? UIViewController,
            container == self.presentedViewController{
            return container.preferredContentSize
        }
        else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override open var frameOfPresentedViewInContainerView: CGRect {
        let containerViewBounds = self.containerView?.bounds
        let presentedViewContentSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: (containerViewBounds?.size)!)        
        let presentedViewControllerFrame = CGRect(x: containerViewBounds!.origin.x, y: containerViewBounds!.maxY - presentedViewContentSize.height, width: (containerViewBounds?.size.width)!, height: presentedViewContentSize.height)
        return presentedViewControllerFrame
    }
    
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.dimmingView?.frame = (self.containerView?.bounds)!
        self.presentationWrappingView?.frame = self.frameOfPresentedViewInContainerView
    }
}

// MARK: - 实现协议UIViewControllerTransitioningDelegate
extension CustomPresentationController {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self;
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentationAnimator()
    }

}
