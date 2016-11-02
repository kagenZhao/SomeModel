//
//  HalfWaySpringAnimator.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit


public func after(delay: TimeInterval, execute closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: closure)
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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let containerView = transitionContext.containerView
        var fromView = fromViewController?.view
        var toView = toViewController?.view
        fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        let isPresenting = (toViewController?.presentingViewController == fromViewController)
        var imageFromFame = CGRect.zero
        var imageToFame = CGRect.zero
        fromView?.alpha = 1
        let tv = transitionView(rect: containerView.bounds)
        if isPresenting {
            imageFromFame = self.frame
            imageToFame = CGRect(origin: CGPoint(x: 20, y: containerView.frame.height / 2.0 - self.frame.height / 2), size: self.frame.size)
            toView?.alpha = 0
            toView!.frame = imageToFame
            tv.alpha = 0;
            containerView.addSubview(tv)
            containerView.addSubview(toView!)
        } else {
            imageFromFame = CGRect(origin: CGPoint(x: 20, y: containerView.frame.height / 2.0 - self.frame.height / 2), size: self.frame.size)
            imageToFame = self.frame
            toView?.alpha = 1
             tv.alpha = 1;
            toView!.frame = fromView!.frame
            containerView.insertSubview(toView!, belowSubview: fromView!)
            containerView.insertSubview(tv, belowSubview: fromView!)
        }
        
        self.image.removeFromSuperview()
        containerView.addSubview(self.image)
        
        func addShadow(comp: (() -> ())?) {
            UIView.animate(withDuration: 0.2, animations: {
                self.image.layer.shadowOffset = CGSize(width: 1, height: 1)
                self.image.layer.shadowColor = UIColor.gray.cgColor
                self.image.layer.shadowOpacity = 1
                self.image.layer.shadowRadius = 10
                self.image.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { _ in
                comp?()
            }
        }
        
        func removeShadow(comp: (() -> ())?) {
            UIView.animate(withDuration: 0.2, animations: {
                self.image.transform = CGAffineTransform.identity
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
            maskLayer.add(animation, forKey: "path")
        }
        
        func presentMaskLayerAnimation() {
            let minw = min(imageToFame.size.width, imageToFame.size.height) / 2
            let w = imageToFame.width
            let h = imageToFame.height
            let rect = CGRect(x: imageToFame.origin.x + ((w - minw) / 2), y: imageToFame.origin.y + ((h - minw) / 2), width: minw, height: minw)
            let startCycle = UIBezierPath(ovalIn: rect)
            let x = max(imageToFame.origin.x, containerView.frame.size.width - imageToFame.origin.x)
            let y = max(imageToFame.origin.y, containerView.frame.size.height - imageToFame.origin.y)
            let radius = sqrtf(pow(Float(x), Float(2)) + pow(Float(y), Float(2)))
            let endCycle = UIBezierPath(arcCenter: containerView.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            maskLayer(view: toView!, start: startCycle.cgPath, end: endCycle.cgPath)
        }
        
        func dismissMaskLayerAnimation() {
            let a = containerView.frame.size.height * containerView.frame.size.height + containerView.frame.size.width * containerView.frame.size.width
            let radius = sqrtf(Float(a)) / 2
            let startCycle = UIBezierPath(arcCenter: containerView.center, radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
            let minw = min(imageFromFame.size.width, imageFromFame.size.height) / 2
            let w = imageFromFame.width
            let h = imageFromFame.height
            let rect = CGRect(x: imageFromFame.origin.x + ((w - minw) / 2), y: imageFromFame.origin.y + ((h - minw) / 2), width: minw, height: minw)
            let endCycle = UIBezierPath(ovalIn: rect)
            maskLayer(view: fromView!, start: startCycle.cgPath, end: endCycle.cgPath)
        }
        
        func endTransition() {
            self.image.removeFromSuperview()
            tv.removeFromSuperview()
            toView?.addSubview(self.image)
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
        
        if isPresenting {
            toView?.frame = transitionContext.finalFrame(for: toViewController!)
            UIView.animate(withDuration: 0.2, animations: { 
                tv.alpha = 1;
            })
            addShadow(comp: {
                UIView.animate(withDuration: 0.5, animations: {
                    self.image.frame = imageToFame
                    }, completion: { _ in
                        removeShadow(comp: {
                            presentMaskLayerAnimation()
                            UIView.animate(withDuration: maskLayerTime, animations: {
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
            after(delay: maskLayerTime - 0.15, execute: {
                addShadow(comp: {
                    fromView?.alpha = 0
                    UIView.animate(withDuration: 0.2, animations: {
                        tv.alpha = 0;
                    })
                    UIView.animate(withDuration: 0.5, animations: {
                        self.image.frame = imageToFame
                        }, completion: { _ in
                            removeShadow(comp: nil)
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
        sv1.backgroundColor = UIColor.lightGray
        sv2.backgroundColor = UIColor.white
        return v
    }
}

