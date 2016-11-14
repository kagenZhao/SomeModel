//
//  ViewController.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/14.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.kqr.setupQRUIInSelf()?
        .set(stopWhenGetFirstQrcode: true)
        .startRunning(decodeNotifier: { (str) in
            print(str)
        })

    }

}

