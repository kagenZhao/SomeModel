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
    s.frame = CGRect(x: 20, y: 30, width: UIScreen.mainScreen().bounds.width - 40, height: 50)
    s.addTarget(self, action: #selector(FourViewController.sliderValueChange(_:)), forControlEvents: .ValueChanged)
    return s
  }()
  override func viewDidLoad() {
    super.viewDidLoad()
    let btn = UIButton(type: .System)
    btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    btn.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
    btn.setTitle("返回", forState: .Normal)
    btn.addTarget(self, action: #selector(self.buttonDidClicked(_:)), forControlEvents: .TouchUpInside)
    view.addSubview(btn)
    
    view.addSubview(slider)
    
    view.backgroundColor = UIColor.orangeColor()
    updatePreferredContentSizeWithTraitCollection(self.traitCollection)
  }
  
  func updatePreferredContentSizeWithTraitCollection(traitCollection: UITraitCollection) {
    self.preferredContentSize = CGSize(width: view.bounds.size.width, height: traitCollection.verticalSizeClass == .Compact ? 270 : 420)
    slider.maximumValue = Float(self.preferredContentSize.height)
    slider.minimumValue = 220
    slider.value = self.slider.maximumValue
  }
  
  override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    updatePreferredContentSizeWithTraitCollection(newCollection)
  }
  
  
  func buttonDidClicked(sender: AnyObject) {
    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  func sliderValueChange(sender: UISlider) {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, CGFloat(sender.value))
  }
  
  
}
