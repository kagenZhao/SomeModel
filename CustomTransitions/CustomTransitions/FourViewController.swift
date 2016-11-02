//
//  FourViewController.swift
//  CustomTransitions
//
//  Created by zhaoguoqing on 16/3/27.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class FourViewController: UIViewController {
    lazy var slider: UISlider =  {
        let s = UISlider()
        s.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width - 40, height: 50)
        s.addTarget(self, action: #selector(FourViewController.sliderValueChange(_:)), for: .valueChanged)
        return s
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(self.buttonDidClicked(_:)), for: .touchUpInside)
        view.addSubview(btn)
        
        view.addSubview(slider)
        
        view.backgroundColor = UIColor.orange
        updatePreferredContentSizeWithTraitCollection(traitCollection: self.traitCollection)
    }
    
    
    func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .compact ? 270 : 420)
        slider.maximumValue = Float(self.preferredContentSize.height)
        slider.minimumValue = 220
        slider.value = self.slider.maximumValue
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSizeWithTraitCollection(traitCollection: newCollection)
    }
    
    
    func buttonDidClicked(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    func sliderValueChange(_ sender: UISlider) {
        self.preferredContentSize = CGSize(width: self.view.bounds.size.width, height: CGFloat(sender.value))
    }
    
    
}
