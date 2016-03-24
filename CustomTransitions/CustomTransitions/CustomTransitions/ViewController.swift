//
//  ViewController.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/13.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var image: UIImageView!
    var sVC = SecondViewController()
    var tVC = ThirdViewController()
    var half: HalfWaySpringAnimator!
    var customTransitionDelegate = InteractivityTransitionDelegate()
    var interactiveTransitionRecognizer: UIScreenEdgePanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        half = HalfWaySpringAnimator(imageview: self.image)
        sVC.transitioningDelegate = self
        sVC.modalPresentationStyle = .FullScreen
        
        interactiveTransitionRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ViewController.interactiveTransitionRecognizerAction(_:)))
        interactiveTransitionRecognizer.edges =  .Right  // [.Right, .Left]
        tVC.transitioningDelegate = customTransitionDelegate
        tVC.modalPresentationStyle = .FullScreen
        self.view.addGestureRecognizer(interactiveTransitionRecognizer)
        
        
    }
    
    @IBAction func 跳转(sender: AnyObject) {
        self.presentViewController(sVC, animated: true, completion: {
        })
    }
    
    @IBAction func 跳转2(sender: AnyObject) {
        self.animationButtonDidClicked(sender)
    }
    
    @IBAction func 跳转3(sender: AnyObject) {
        
    }
    
    
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return half
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return half
    }
    
    
    func interactiveTransitionRecognizerAction(sender: UIScreenEdgePanGestureRecognizer) {
        /**
         *  在开始触发手势时，调用animationButtonDidClicked方法，只会调用一次
         */
        if sender.state == .Began {
            animationButtonDidClicked(sender)
        }
    }
    
    func animationButtonDidClicked(sender: AnyObject) {
        if sender.isKindOfClass(UIGestureRecognizer) {
            customTransitionDelegate.gestureRecognizer = interactiveTransitionRecognizer
        } else {
            customTransitionDelegate.gestureRecognizer = nil
        }
        customTransitionDelegate.targetEdge = .Right
        self.presentViewController(tVC, animated: true, completion: nil)
    }
    
    
}
