//
//  ViewController.swift
//  KMRAlert
//
//  Created by zhaoguoqing on 16/4/19.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIActionSheetDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func alert(sender: AnyObject) {
        KMRAlert(controller: self, title: "title", message: "message", type: .Alert)
            .addActionWithTitle("action1", action: nil)
            .addTextField({ (tf) in
                
                }, changed: { (tf) in
                   print(tf?.text)
            })
            .addActionWithTitle("aaa", action: nil)
            .show()
    }
}

