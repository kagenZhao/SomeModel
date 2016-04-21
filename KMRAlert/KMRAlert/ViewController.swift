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
        
        
        if #available(iOS 8.0, *) {
            
            KMRAlert(controller: self/* or nil */, title: "title", message: "message", type: .Alert)
                .addAction("1", act: nil)
                .addAction("2", action: nil)
                .addAction("3", actionStyle: .Destructive, action: nil)
                .addAction("4", enable: true, action: nil)
                .addAction("5", actionStyle: .Default, enable: false, action: { (action) in
                    
                })
                .addTextField({ (textField) in
                    
                    textField?.placeholder = "textField1"
                    
                    }, changed: { (textField) in
                        
                        print("textField1 - \(textField?.text)")
                })
                .addTextFieldWithAction({ (textField) in
                    textField?.placeholder = "textField2"
                })
                .addTextFieldWithChanged({ (textField) in
                    print("textField2 - \(textField?.text)")
                })
                .show()
        }
    }
}

