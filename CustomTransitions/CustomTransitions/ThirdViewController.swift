//
//  ThirdViewController.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    
    var interactiveTransitionRecognizer: UIScreenEdgePanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
        let btn = UIButton(type: .System)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        btn.setTitle("返回", forState: .Normal)
        btn.addTarget(self, action: #selector(self.buttonDidClicked(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
        
        
        interactiveTransitionRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ThirdViewController.interactiveTransitionRecognizerAction(_:)))
        
        interactiveTransitionRecognizer.edges = .Left
        self.view.addGestureRecognizer(interactiveTransitionRecognizer)
        
        
    }
    
    
    func interactiveTransitionRecognizerAction(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Began {
            self.buttonDidClicked(sender)
        }
    }
    
    func buttonDidClicked(sender: AnyObject) {
        if let transitionDelegate = self.transitioningDelegate as? InteractivityTransitionDelegate {
            if sender.isKindOfClass(UIGestureRecognizer) {
                transitionDelegate.gestureRecognizer = interactiveTransitionRecognizer
            }
            else {
                transitionDelegate.gestureRecognizer = nil
            }
            transitionDelegate.targetEdge = .Left
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
