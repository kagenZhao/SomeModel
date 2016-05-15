//
//  HalfWaySpringAnimator.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

func after(time: Double, action: dispatch_block_t?) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(time * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
        action?()
    })
}

class HalfWaySpringAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var image: UIImageView
    var imageSuperView: UIView
    var frame: CGRect
    init(imageview: UIImageView){
        self.image = imageview
        self.imageSuperView = imageview.superview!
        self.frame = imageview.frame
    }
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
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
        
        let isPresenting = (toViewController?.presentingViewController == fromViewController)
        var imageFromFame = CGRectZero
        var imageToFame = CGRectZero
        fromView?.alpha = 1
        let tv = transitionView(containerView!.bounds)
        if isPresenting {
            imageFromFame = self.frame
            imageToFame = CGRect(origin: CGPoint(x: 20, y: containerView!.frame.height / 2.0 - self.frame.height / 2), size: self.frame.size)
            toView?.alpha = 0
            toView!.frame = imageToFame
            tv.alpha = 0;
            containerView?.addSubview(tv)
            containerView?.addSubview(toView!)
        } else {
            imageFromFame = CGRect(origin: CGPoint(x: 20, y: containerView!.frame.height / 2.0 - self.frame.height / 2), size: self.frame.size)
            imageToFame = self.frame
            toView?.alpha = 1
             tv.alpha = 1;
            toView!.frame = fromView!.frame
            containerView?.insertSubview(toView!, belowSubview: fromView!)
            containerView?.insertSubview(tv, belowSubview: fromView!)
        }
        
        self.image.removeFromSuperview()
        containerView?.addSubview(self.image)
        
        func addShadow(comp: dispatch_block_t?) {
            UIView.animateWithDuration(0.2, animations: {
                self.image.layer.shadowOffset = CGSizeMake(1, 1)
                self.image.layer.shadowColor = UIColor.grayColor().CGColor
                self.image.layer.shadowOpacity = 1
                self.image.layer.shadowRadius = 10
                self.image.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }) { _ in
                comp?()
            }
        }
        
        func removeShadow(comp: dispatch_block_t?) {
            UIView.animateWithDuration(0.2, animations: {
                self.image.transform = CGAffineTransformIdentity
                self.image.layer.shadowOpacity = 0
                self.image.layer.shadowRadius = 0
            }) { _ in
                comp?()
            }
        }
        
        let maskLayerTime = 0.5
        
        func maskLayer(view: UIView, start: CGPath, end: CGPath) {
            let maskLayer = CAShapeLayer()
            maskLayer.path = end
            view.layer.mask = maskLayer
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = start
            animation.toValue = end
            animation.duration = maskLayerTime
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.setValue(transitionContext, forKey: "transitionContext")
            maskLayer.addAnimation(animation, forKey: "path")
        }
        
        func presentMaskLayerAnimation() {
            let minw = min(imageToFame.size.width, imageToFame.size.height) / 2
            let w = imageToFame.width
            let h = imageToFame.height
            let rect = CGRect(x: imageToFame.origin.x + ((w - minw) / 2), y: imageToFame.origin.y + ((h - minw) / 2), width: minw, height: minw)
            let startCycle = UIBezierPath(ovalInRect: rect)
            let x = max(imageToFame.origin.x, containerView!.frame.size.width - imageToFame.origin.x)
            let y = max(imageToFame.origin.y, containerView!.frame.size.height - imageToFame.origin.y)
            let radius = sqrtf(pow(Float(x), Float(2)) + pow(Float(y), Float(2)))
            let endCycle = UIBezierPath(arcCenter: containerView!.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            maskLayer(toView!, start: startCycle.CGPath, end: endCycle.CGPath)
        }
        
        func dismissMaskLayerAnimation() {
            let a = containerView!.frame.size.height * containerView!.frame.size.height + containerView!.frame.size.width * containerView!.frame.size.width
            let radius = sqrtf(Float(a)) / 2
            let startCycle = UIBezierPath(arcCenter: containerView!.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            let minw = min(imageFromFame.size.width, imageFromFame.size.height) / 2
            let w = imageFromFame.width
            let h = imageFromFame.height
            let rect = CGRect(x: imageFromFame.origin.x + ((w - minw) / 2), y: imageFromFame.origin.y + ((h - minw) / 2), width: minw, height: minw)
            let endCycle = UIBezierPath(ovalInRect: rect)
            maskLayer(fromView!, start: startCycle.CGPath, end: endCycle.CGPath)
        }
        
        func endTransition() {
            self.image.removeFromSuperview()
            tv.removeFromSuperview()
            toView?.addSubview(self.image)
            let wasCancelled = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!wasCancelled)
        }
        
        if isPresenting {
            toView?.frame = transitionContext.finalFrameForViewController(toViewController!)
            UIView.animateWithDuration(0.2, animations: { 
                tv.alpha = 1;
            })
            addShadow({
                UIView.animateWithDuration(0.5, animations: {
                    self.image.frame = imageToFame
                    }, completion: { _ in
                        removeShadow({
                            presentMaskLayerAnimation()
                            UIView.animateWithDuration(maskLayerTime, animations: {
                                toView?.alpha = 1.0
                            }) { _ in
                                endTransition()
                            }
                        })
                })
            })
        } else {
            fromView?.frame = toView!.frame
            dismissMaskLayerAnimation()
            after(maskLayerTime - 0.15, action: {
                addShadow({
                    fromView?.alpha = 0
                    UIView.animateWithDuration(0.2, animations: {
                        tv.alpha = 0;
                    })
                    UIView.animateWithDuration(0.5, animations: {
                        self.image.frame = imageToFame
                        }, completion: { _ in
                            removeShadow(nil)
                            endTransition()
                    })
                })
            })
        }
    }
    
    func transitionView(rect: CGRect) -> UIView {
        let v = UIView(frame: rect)
        let sv1 = UIView(frame: CGRect(x: 0, y: 0, width: rect.width, height: rect.height / 2.0))
        let sv2 = UIView(frame: CGRect(x: 0, y: rect.height / 2.0, width: rect.width, height: rect.height))
        v.addSubview(sv1)
        v.addSubview(sv2)
        sv1.backgroundColor = UIColor.lightGrayColor()
        sv2.backgroundColor = UIColor.whiteColor()
        return v
    }
}

