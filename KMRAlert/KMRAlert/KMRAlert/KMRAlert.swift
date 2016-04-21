//
//  KMRAlert.swift
//  Oeasy
//
//  Created by 赵国庆 on 16/1/19.
//  Copyright © 2016年 zhangjinghao. All rights reserved.
//

import UIKit

enum KMRAlertType: Int {
    case ActionSheet
    case Alert
}

enum KMRActionStyle: Int {
    case Default = 0
    case Destructive = 2
}

private enum KMRAlertStyle {
    case Old
    case New
}

private struct KMRAssociatedKeys {
    static var kSaveKMRAletKey = "kSaveKMRAletKey"
    static var kTextFieldDidChangeKey = "kTextFieldDidChangeKey"
}

private let KMRAlertID = "KMRCurrentAlert"


// MARK: 初始化
class KMRAlert: NSObject, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate {
    private var currentAlert: AnyObject?
    private var actionArr = [dispatch_block_t]()
    weak private var showController: UIViewController?
    private(set) var alertType: KMRAlertType = .Alert
    private var alertStyle: KMRAlertStyle = .Old
    private var oldAlertViewFirstTextFieldAction: ((UITextField?) -> ())?
    private var oldAlertViewFirstTextFieldChanged: ((UITextField?) -> ())?
    private var textFieldCount: Int = 0;
    
    init(controller: UIViewController?, title: String?, message: String?, type: KMRAlertType) {
        super.init()
        guard type.rawValue >= 0 && type.rawValue <= 1 else {
            KMRLog("KMRAlertType must be (0 or 1)")
            return
        }
        self.saveAlert(self)
        self.alertType = type
        self.alertStyle = getAlertStyle(controller)
        self.showController = controller
        func oldAlert() {
            let alertView = UIAlertView()
            if title != nil { alertView.title = title! }
            alertView.message = message
            alertView.delegate = self
            self.currentAlert = alertView
        }
        
        func oldActionSheet() {
            let actionSheet = UIActionSheet()
            if title != nil { actionSheet.title = title! }
            actionSheet.delegate = self
            self.currentAlert = actionSheet
            if message != nil {
                KMRLog("UIActionSheet Cannot Add Message")
            }
        }
        
        func newAlertController () {
            if #available (iOS 8.0, *) {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle(rawValue: type.rawValue)!)
                self.currentAlert = alertController
            }
        }
        
        switch (self.alertStyle, self.alertType) {
        case (.Old, .Alert):
            oldAlert()
        case (.Old, .ActionSheet):
            oldActionSheet()
        case (.New, .ActionSheet), (.New, .Alert):
            newAlertController()
        }
    }
    
    convenience init(controller: UIViewController?, title: String?, type: KMRAlertType) {
        self.init(controller: controller, title: title, message: nil, type: type)
    }
    
    convenience init(controller: UIViewController?, message: String?, type: KMRAlertType) {
        self.init(controller: controller, title: nil, message: message, type: type)
    }
    
    convenience init(controller: UIViewController?, type: KMRAlertType) {
        self.init(controller: controller, title: nil, message: nil, type: type)
    }
    
    convenience init(title: String?, message: String?, type: KMRAlertType) {
        self.init(controller: nil, title: title, message: message, type: type)
    }
    
    convenience init(title: String?, type: KMRAlertType) {
        self.init(controller: nil, title: title, message: nil, type: type)
    }
    
    convenience init(message: String?, type: KMRAlertType) {
        self.init(controller: nil, title: nil, message: message, type: type)
    }
    
    convenience init(type: KMRAlertType) {
        self.init(controller: nil, title: nil, message: nil, type: type)
    }
    
    deinit {
        KMRLog(self)
    }
}

// MARK: AddAction
extension KMRAlert {
    
    @available(iOS 8.0, *)
    func addAction(title: String?, actionStyle: KMRActionStyle, enable: Bool, action: ((UIAlertAction) -> ())?) -> KMRAlert {
        guard self.showController != nil else {
            KMRLog("If Use addAction(title: actionStyle: enable: action:) , Controller cannot be nil")
            return self
        }
        if let temp = self.currentAlert {
            guard actionStyle.rawValue == 0 || actionStyle.rawValue == 2 else {
                KMRLog("KMRActionStyle must be (0 or 2)")
                return self
            }
            let alert = temp as! UIAlertController
            let alertStyle = UIAlertActionStyle(rawValue: actionStyle.rawValue)!
            let alertAction = UIAlertAction(title: title, style: alertStyle, handler: { (act) in
                action?(act)
                self.remove()
            })
            alertAction.enabled = enable
            alert.addAction(alertAction)
        }
        return self
    }
    @available(iOS 8.0, *)
    func addAction(title: String?, enable: Bool, action: ((UIAlertAction) -> ())?) -> KMRAlert {
        return addAction(title, actionStyle: .Default, enable: enable, action: action)
    }
    @available(iOS 8.0, *)
    func addAction(title:String?, action: ((UIAlertAction) -> ())?) -> KMRAlert {
        return addAction(title, enable: true, action: action)
    }
    
    func addAction(title: String?, act: (() -> ())?) -> KMRAlert {
        return self.addAction(title, actionStyle: .Default, action: act)
    }
    func addAction(title: String?, actionStyle: KMRActionStyle, action: (() -> ())?) -> KMRAlert {
        let newAction = { [unowned self] in
            action?()
            self.remove()
        }
        if let temp = self.currentAlert {
            switch (self.alertStyle, self.alertType) {
            case (.Old, .Alert):
                let alert = temp as! UIAlertView
                alert.addButtonWithTitle(title)
                self.actionArr.append(newAction)
                if actionStyle == .Destructive {
                    KMRLog("UIAlertView Cannot Add A Destructive Action")
                }
            case (.Old, .ActionSheet):
                let alert = temp as! UIActionSheet
                alert.addButtonWithTitle(title)
                self.actionArr.append(newAction)
                if actionStyle == .Destructive {
                    KMRLog("UIActionSheet Cannot Add A Destructive Action")
                }
            case (.New, .Alert), (.New, .ActionSheet):
                if #available(iOS 8.0, *) {
                    addAction(title, enable: true, action: { _ in
                        newAction()
                    })
                }
            }
        } else {
            KMRLog("Please init")
        }
        return self
    }
    
}

// MARK: AddTextField
extension KMRAlert {
    
    func addTextFieldWithAction(action:((UITextField?) -> Void)?) -> KMRAlert {
        return addTextField(action, changed: nil)
    }
    
    func addTextFieldWithChanged(changed: ((UITextField?) -> Void)?) -> KMRAlert {
        return addTextField(nil, changed: changed)
    }
    
    func addTextField(action: ((UITextField?) -> Void)?, changed:((UITextField?) -> Void)?) -> KMRAlert {
        if let temp = self.currentAlert {
            switch (self.alertStyle, self.alertType) {
            case (.Old, .Alert):
                let alert = temp as! UIAlertView
                if self.textFieldCount == 0 {
                    alert.alertViewStyle = .PlainTextInput
                    let tf = alert.textFieldAtIndex(0)
                    tf?.delegate = self
                    self.oldAlertViewFirstTextFieldAction = action
                    self.oldAlertViewFirstTextFieldChanged = changed
                    action?(tf)
                    tf?.addChangeNotification(changed)
                    self.textFieldCount = 1;
                } else if self.textFieldCount == 1 {
                    alert.alertViewStyle = .LoginAndPasswordInput
                    let tf1 = alert.textFieldAtIndex(0)
                    let tf2 = alert.textFieldAtIndex(1)
                    tf1?.placeholder = nil
                    tf1?.secureTextEntry = false
                    tf2?.placeholder = nil
                    tf2?.secureTextEntry = false
                    tf1?.delegate = self
                    tf2?.delegate = self
                    tf1?.addChangeNotification(oldAlertViewFirstTextFieldChanged)
                    tf2?.addChangeNotification(changed)
                    oldAlertViewFirstTextFieldAction?(tf1)
                    action?(tf2)
                    self.textFieldCount = 2
                } else {
                    KMRLog("UIAlertView AddTextField Num Greater Than 2");
                }
            case (.Old, .ActionSheet), (.New, .ActionSheet):
                KMRLog("ActionSheet Cannot AddTextField")
            case (.New, .Alert):
                if #available(iOS 8.0, *) {
                    let alertController = temp as! UIAlertController
                    alertController.addTextFieldWithConfigurationHandler({ (textField) in
                        textField.delegate = self;
                        textField.addChangeNotification(changed)
                        action?(textField)
                    })
                    alertController.view.setNeedsUpdateConstraints()
                }
            }
        } else {
            KMRLog("Please init")
        }
        return self
    }
}

// MARK: Show
extension KMRAlert {
    func show() {
        guard let someAlert = currentAlert else {
            KMRLog("Please init")
            return
        }
        switch self.alertStyle {
        case .New:
            if #available (iOS 8.0, *) {
                let alertController = someAlert as! UIAlertController
                for action in alertController.actions {
                    switch action.style {
                    case .Default, .Cancel:
                        action.setValue(KMRHexColor(0x0079ff), forKey: "_titleTextColor")
                    case .Destructive:
                        action.setValue(KMRHexColor(0xff3b30), forKey: "_titleTextColor")
                    }
                }
                self.showController?.presentViewController(alertController, animated: true, completion: nil)
            }
        case .Old:
            if self.alertType == .Alert {
                let alertView = someAlert as! UIAlertView
                alertView.show()
            } else {
                let actionSheet = someAlert as! UIActionSheet
                if let window = UIApplication.sharedApplication().keyWindow {
                    actionSheet.showInView(window)
                } else {
                    KMRLog("actionSheet show error: UIApplication.sharedApplication().keyWindow cannot be nil")
                    KMRMainAfter(0.5, action: { [unowned self] in
                        self.show()
                    })
                }
            }
        }
    }
}

// MARK: Delegate
extension KMRAlert {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let action = self.actionArr[buttonIndex];
        action();
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let action = self.actionArr[buttonIndex];
        action();
    }
}

// MARK: Tools
extension KMRAlert {
    private func getAlertStyle(controller: UIViewController?) -> KMRAlertStyle {
        if controller != nil {
            if #available (iOS 8.0, *) {
                return .New
            } else {
                return .Old
            }
        } else {
            return .Old;
        }
    }
    
    private func saveAlert(alert: AnyObject) {
        let app = UIApplication.sharedApplication()
        objc_setAssociatedObject(app, &KMRAssociatedKeys.kSaveKMRAletKey, alert, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func getAlert() -> KMRAlert? {
        let app = UIApplication.sharedApplication()
        return objc_getAssociatedObject(app, &KMRAssociatedKeys.kSaveKMRAletKey) as? KMRAlert
    }
    
    private func remove() {
        KMRMainAfter(0.3) {
            guard self.getAlert() != nil else { return }
            let app = UIApplication.sharedApplication()
            objc_setAssociatedObject(app, &KMRAssociatedKeys.kSaveKMRAletKey, NSNull(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: TextFieldChangeNotification
extension UITextField: UITextFieldDelegate {
    private typealias TimerExcuteClosure = @convention(block) (UITextField)->()
    private func addChangeNotification(action:((UITextField) -> ())?) {
        if let act = action {
            self.delegate = self
            self.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
            let wrappedBlock:@convention(block) (UITextField)->Void={ tf in
                act(tf)
            }
            let wappedObject: AnyObject = unsafeBitCast(wrappedBlock, AnyObject.self)
            objc_setAssociatedObject(self, &KMRAssociatedKeys.kTextFieldDidChangeKey, wappedObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func textFieldDidChange(textField: UITextField) {
        let wappedObject = objc_getAssociatedObject(self, &KMRAssociatedKeys.kTextFieldDidChangeKey)
        let wrappedBlock:@convention(block) (UITextField)->Void = unsafeBitCast(wappedObject, TimerExcuteClosure.self)
        
        
        guard let lang = textField.textInputMode?.primaryLanguage else { return }
        if lang == "zh-Hans" {
            guard let selectedRange = textField.markedTextRange else {
                wrappedBlock(textField)
                return
            }
            let position = textField.positionFromPosition(selectedRange.start, offset: 0)
            if ((position == nil)) {
                wrappedBlock(textField)
            }
        }
        else{
            wrappedBlock(textField)
        }
    }
}


// MARK: Other Tools
private func KMRHexColor(rgbValue: UInt64) ->UIColor {
    // 16进制颜色
    let r = CGFloat((rgbValue & 0xff0000) >> 16) / 255.0
    let g = CGFloat((rgbValue & 0xff00) >> 8) / 255.0
    let b = CGFloat(rgbValue & 0xff) / 255.0
    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
    return color
}

private func KMRLog(message: AnyObject?, filename: String = #file, line: Int = #line, function: String = #function) {
    if let mes = message {
        print("\((filename as NSString).lastPathComponent):\(line) \(function): \(mes)")
    } else {
        print("\((filename as NSString).lastPathComponent):\(line) \(function): (null)")
    }
}

private func KMRBack(block: (() -> ()), queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
    dispatch_async(queue, block)
}

private func KMRMain(block: (() -> ())) {
    dispatch_async(dispatch_get_main_queue(),block)
}

private func KMRAfter(time: Double, queue: dispatch_queue_t, action: dispatch_block_t?) {
    let newAction = (action != nil) ? action : {}
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((time * Double(NSEC_PER_SEC)))), queue, newAction!)
}

private func KMRMainAfter(time: Double, action: (() -> ())?) {
    let queue = dispatch_get_main_queue()
    KMRAfter(time, queue: queue, action: action)
}

private func KMRbackAfter(time: Double, action: (() -> ())?) {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    KMRAfter(time, queue: queue, action: action)
}





