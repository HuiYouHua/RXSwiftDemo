//
//  ViewController.swift
//  39通知NotificationCenter的使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let observers = [MyObserver(name: "观察器1"),MyObserver(name: "观察器2")]

    override func viewDidLoad() {
        super.viewDidLoad()
        // 监听应用进入后台通知
        _ = NotificationCenter.default.rx
            .notification(NSNotification.Name.NSExtensionHostDidEnterBackground)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("程序进入到后台了")
            })
        
        //添加文本输入框
        let textField = UITextField(frame: CGRect(x:20, y:100, width:200, height:30))
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        self.view.addSubview(textField)
        
        //点击键盘上的完成按钮后，收起键盘
        textField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: {  _ in
                //收起键盘
                textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        //监听键盘弹出通知
        _ = NotificationCenter.default.rx
            .notification(UIResponder.keyboardDidShowNotification)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("键盘出现了")
            })
        
        //监听键盘隐藏通知
        _ = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { _ in
                print("键盘消失了")
            })
        
        print("发送通知")
        let notificationName = Notification.Name(rawValue: "DownloadImageNotification")
        NotificationCenter.default.post(name: notificationName, object: self,
                                        userInfo: ["value1":"hangge.com", "value2" : 12345])
        print("通知完毕")
    }
    
    
}

class MyObserver: NSObject {
    
    var name:String = ""
    
    init(name:String){
        super.init()
        
        self.name = name
        
        // 接收通知：
        let notificationName = Notification.Name(rawValue: "DownloadImageNotification")
        _ = NotificationCenter.default.rx
            .notification(notificationName)
            .takeUntil(self.rx.deallocated) //页面销毁自动移除通知监听
            .subscribe(onNext: { notification in
                //获取通知数据
                let userInfo = notification.userInfo as! [String: AnyObject]
                let value1 = userInfo["value1"] as! String
                let value2 = userInfo["value2"] as! Int
                print("\(name) 获取到通知，用户数据是［\(value1),\(value2)］")
                //等待3秒
                sleep(3)
                print("\(name) 执行完毕")
            })
    }
}
