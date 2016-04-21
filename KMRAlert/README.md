# KMRAlertKit
- Swift编写对UIAlertView, UIActionSheet, UIAlertController的封装
- 支持iOS7以上的系统
- 支持添加输入框(iOS8以下只支持两个输入框)
- 支持对输入框添加监听事件
- iOS8以上支持UIAlertAction的enable
- 一些关于适配的错误 会有打印警告 
####例:
```
if #available(iOS 8.0, *) {
      KMRAlert(controller: self/* or nil */, title: "title", message: "message", type: .Alert)
       .addAction("1", act: nil)
       .addAction("2", action: nil)
       .addAction("3", actionStyle: .Destructive, action: nil)
       .addAction("4", enable: true, action: nil)
       .addAction("5", actionStyle: .Default, enable: false, action: { (action) in
             /* do something */       
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
```
