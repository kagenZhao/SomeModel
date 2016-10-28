//
//  KZWifiDidChangedNotification.swift
//  NetWorkReachabilityTest
//
//  Created by Kagen Zhao on 2016/10/12.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork


/// WiFi 信息类
///
/// 包含 bssid, ssid , ssidData
public struct KZWiFiInfo {
    
    /// WIFI MAC地址
    public private(set) var bssid: String
    
    /// WIFI 名称
    public private(set) var ssid: String
    
    /// 检测当前实例是否是空
    public var isEmpty: Bool { return bssid == "" && ssid == ""}
    
    private init() {
        self.bssid = ""
        self.ssid = ""
    }
    
    /// 唯一初始化方法
    public init(bssid: String?, ssid: String?) {
        self.bssid = (bssid == nil || bssid!.characters.count == 0) ? "" : bssid!
        self.ssid = (ssid == nil || ssid!.characters.count == 0) ? "" : ssid!
    }
    
    /// return a empty WiFiInfo
    public static var empty: KZWiFiInfo {
        return KZWiFiInfo()
    }
}

extension KZWiFiInfo: Equatable {
    
    
    public static func ==(lhs: KZWiFiInfo, rhs: KZWiFiInfo) -> Bool {
        if lhs.isEmpty && rhs.isEmpty { return true }
        else if lhs.bssid == rhs.bssid && lhs.ssid == lhs.ssid { return true }
        else { return false }
    }
}

// MARK: - 用于监听的 NotificationName
extension Notification.Name {
    public struct KZWiFi {
        public static let DidChange = Notification.Name(rawValue: "com.kagen.wifiManager")
    }
}

extension CFNotificationName {
    fileprivate struct KZWiFi {
        fileprivate static let NotifyName = CFNotificationName("com.apple.system.config.network_change" as CFString)
    }
}

public typealias KZWifiDidChangedCallBack = (KZWiFiInfo) -> Void

private let single = KZWiFiDidChangedManager()




/// 此类用于仅监听 <有无WIFI> 和 <WIFI地址的改变>
///
/// 如非特殊情况, 一般几乎用不到
public class KZWiFiDidChangedManager {
    private var observer: UnsafeMutableRawPointer!
    
    /// 保存的当前的WiFi信息
    public fileprivate(set) var savedWiFiInfo = KZWiFiDidChangedManager.getCurrentWiFiInfo()
    
    /// 是否已经添加了监听 - 仅指当前这个实例
    public private(set) var addedNotify = false
    
    /// wifi改变后 执行的回调
    public var wifiChangeCallBack: KZWifiDidChangedCallBack?
    
    /// 单例 (可用可不用, 最好不用, 自行管理其生命周期)
    public class var shared:KZWiFiDidChangedManager { return single }
    
    public init() {
        observer = Unmanaged.passUnretained(self).toOpaque()
    }
    
    /// 添加 wifi 监听
    public func addNotify() {
        guard !addedNotify else { return }
        let callBcak: CFNotificationCallback = { (_,observer,name,_,_) in
            guard let name = name else { return }
            if name.rawValue == CFNotificationName.KZWiFi.NotifyName.rawValue {
                guard let observer = observer else { return }
                let manager = Unmanaged<KZWiFiDidChangedManager>.fromOpaque(observer).takeUnretainedValue()
                manager.onNotifyCallBack()
            } else {
                print("other Notification: \(name.rawValue)")
            }
        }
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, callBcak, CFNotificationName.KZWiFi.NotifyName.rawValue, nil, .deliverImmediately)
        addedNotify = true
    }
    
    
    /// 移除 wifi 监听
    public func removeNotify() {
        guard addedNotify else { return }
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), observer, CFNotificationName.KZWiFi.NotifyName, nil)
        addedNotify = false
    }
    
    
    private func onNotifyCallBack() {
        guard update() else { return }
        notifyPush()
    }
    
    private func notifyPush() {
        wifiChangeCallBack?(savedWiFiInfo)
        
        NotificationCenter.default.post(name: Notification.Name.KZWiFi.DidChange, object: savedWiFiInfo, userInfo: nil)
    }
    
}

extension KZWiFiDidChangedManager {
    
    
    /// 更新savedWiFiInfo
    ///
    /// - returns: 返回是否有新的变化
    
    @discardableResult
    public func update() -> Bool {
        let currentInfo = KZWiFiDidChangedManager.getCurrentWiFiInfo()
        guard savedWiFiInfo != currentInfo else { return false }
        guard !(savedWiFiInfo.isEmpty && currentInfo.isEmpty) else { return false }
        savedWiFiInfo = currentInfo
        return true
    }
    
    /// 获取当前WiFi信息
    ///
    /// - returns: Current KZWiFiInfo
    public class func getCurrentWiFiInfo() -> KZWiFiInfo {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            return KZWiFiInfo.empty
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            return KZWiFiInfo.empty
        }
        var info: KZWiFiInfo = KZWiFiInfo.empty
        for interface in swiftInterfaces {
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
                return info
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                return info
            }
            info = KZWiFiInfo(bssid: SSIDDict["BSSID"] as! String?, ssid: SSIDDict["SSID"] as! String?)
        }
        return info
    }
}




