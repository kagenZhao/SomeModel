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
        self.view.backgroundColor = UIColor.orange
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(self.buttonDidClicked(_:)), for: .touchUpInside)
        view.addSubview(btn)
        
        
        interactiveTransitionRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ThirdViewController.interactiveTransitionRecognizerAction(_:)))
        
        interactiveTransitionRecognizer.edges = .left
        self.view.addGestureRecognizer(interactiveTransitionRecognizer)
        
        
    }
    
    
    func interactiveTransitionRecognizerAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            self.buttonDidClicked(sender)
        }
    }
    
    func buttonDidClicked(_ sender: AnyObject) {
        if let transitionDelegate = self.transitioningDelegate as? InteractivityTransitionDelegate {
            if let _ = sender as? UIGestureRecognizer {
                transitionDelegate.gestureRecognizer = interactiveTransitionRecognizer
            }
            else {
                transitionDelegate.gestureRecognizer = nil
            }
            transitionDelegate.targetEdge = .left
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
