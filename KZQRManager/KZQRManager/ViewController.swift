//
//  ViewController.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController {
    
    @IBOutlet weak var iiimage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        /// 在本vc 添加一个 扫码界面
        self.kqr.setupQRUIInSelf()?
//        .setPreviewLayerFrameInSuperLayer(CGRect(x: 100, y: 100, width: 100, height: 100))
//        .setOutputRectOfInterest(CGRect(x: 0.2, y: 0.3, width: 0.5, height: 0.5))
        .startRunning { print($0) }
        
        
        
        
        
        // 生成一个 二维码
        let image = "sssssssssss".kqr.encodeQR()!
        iiimage.image = image
    }
}


