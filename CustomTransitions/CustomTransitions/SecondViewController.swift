//
//  SecondViewController.swift
//  RxSwiftDemo
//
//  Created by zhaoguoqing on 16/3/23.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orange
        let btn = UIButton(type: .system)
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        btn.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        btn.setTitle("返回", for: .normal)
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        view.addSubview(btn)
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
}
