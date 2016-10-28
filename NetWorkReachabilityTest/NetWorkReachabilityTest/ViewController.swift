//
//  ViewController.swift
//  NetWorkReachabilityTest
//
//  Created by Kagen Zhao on 2016/10/12.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var manager = KZNetworkReachabilityManager.shared
    
    override func viewDidLoad() {
        manager?.receiveWiFiChangeNotify = true
        manager?.receiveTechnologyChangeNotify = true
        manager?.startMonitoring()
        
        NotificationCenter.default.addObserver(self, selector: #selector(action(notify:)), name: NSNotification.Name.KZReachability.DidChange, object: nil)
    
        
        super.viewDidLoad()
        
    }
    
    @objc func action(notify: Notification) {
        print(notify.userInfo![KZNetworkReachabilityNotificationItem]!)
    }
}
