//
//  ViewController.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kqr.setupQRUIInSelf()?
        //.setPreviewLayerFrameInSuperLayer(CGRect(x: 100, y: 100, width: 100, height: 100))
        //.setOutputRectOfInterest(CGRect(x: 0.2, y: 0.3, width: 0.5, height: 0.5))
        .startRunning { (str) in
            print(str)
        }
    }
}


