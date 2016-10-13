//
//  AppDelegate.swift
//  NetWorkReachabilityTest
//
//  Created by Kagen Zhao on 2016/10/12.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        var newBgTaskId = UIBackgroundTaskInvalid
        newBgTaskId = application.beginBackgroundTask(expirationHandler: {
          application.endBackgroundTask(newBgTaskId)
        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

