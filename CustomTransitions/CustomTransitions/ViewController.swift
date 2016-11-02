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
    var fVC = FourViewController()
    var half: HalfWaySpringAnimator!
    var customTransitionDelegate = InteractivityTransitionDelegate()
    var customPresentTationController: CustomPresentationController!
    var interactiveTransitionRecognizer: UIScreenEdgePanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        half = HalfWaySpringAnimator(imageview: self.image)
        sVC.transitioningDelegate = self
        sVC.modalPresentationStyle = .fullScreen
        
        interactiveTransitionRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ViewController.interactiveTransitionRecognizerAction(_:)))
        interactiveTransitionRecognizer.edges =  .right  // [.Right, .Left]
        tVC.transitioningDelegate = customTransitionDelegate
        tVC.modalPresentationStyle = .fullScreen
        self.view.addGestureRecognizer(interactiveTransitionRecognizer)
        
        
        customPresentTationController = CustomPresentationController(presentedViewController: self.fVC, presenting: self)
        fVC.transitioningDelegate = customPresentTationController
        
    }
    
    @IBAction func 跳转(_ sender: AnyObject) {
        self.present(sVC, animated: true, completion: {
        })
    }
    
    @IBAction func 跳转2(_ sender: AnyObject) {
        self.animationButtonDidClicked(sender)
    }
    
    @IBAction func 跳转3(_ sender: AnyObject) {
        self.present(fVC, animated: true, completion: nil)
    }
    

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return half
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return half
    }

    
    func interactiveTransitionRecognizerAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        /**
         *  在开始触发手势时，调用animationButtonDidClicked方法，只会调用一次
         */
        if sender.state == .began {
            animationButtonDidClicked(sender)
        }
    }
    
    func animationButtonDidClicked(_ sender: AnyObject) {
        if let _ = sender as? UIGestureRecognizer {
            customTransitionDelegate.gestureRecognizer = interactiveTransitionRecognizer
        } else {
            customTransitionDelegate.gestureRecognizer = nil
        }
        customTransitionDelegate.targetEdge = .right
        self.present(tVC, animated: true, completion: nil)
    }
    
    
}
