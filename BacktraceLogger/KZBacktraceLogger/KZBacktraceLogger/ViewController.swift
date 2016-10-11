//
//  ViewController.swift
//  KZBacktraceLogger
//
//  Created by Kagen Zhao on 2016/10/10.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _ = KZBacktraceLogger.kz_backtraceOfAllThread()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

