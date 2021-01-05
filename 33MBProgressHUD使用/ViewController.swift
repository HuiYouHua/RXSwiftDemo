//
//  ViewController.swift
//  33MBProgressHUD使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func test1() {
        //初始化HUD窗口，并置于当前的View当中显示
        //初始化HUD窗口，并置于当前的View当中显示
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //纯文本模式
        hud.mode = .text
        //设置提示文字
        hud.label.text = "请稍等"
        //设置提示详情
        hud.detailsLabel.text = "具体要等多久我也不知道"
        hud.backgroundView.style = .blur //模糊的遮罩背景
        hud.bezelView.layer.cornerRadius = 20.0 //设置提示框圆角
        hud.label.textColor = .orange //标题文字颜色
        hud.label.font = UIFont.systemFont(ofSize: 20) //标题文字字体
        hud.detailsLabel.textColor = .blue //详情文字颜色
        hud.detailsLabel.font = UIFont.systemFont(ofSize: 11) //详情文字字体
        //将菊花设置成橙色
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = .orange
        hud.offset = CGPoint(x:-100, y:-150) //向左偏移100，向上偏移150
        hud.margin = 0 //将各个元素与矩形边框的距离设为0
        hud.minSize = CGSize(width: 250, height: 110) //设置最小尺寸
        hud.isSquare = true //正方形提示框
        //HUD窗口显示2秒后自动隐藏
        hud.hide(animated: true, afterDelay: 2)
        
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.label.text = "请稍等"
//        hud.removeFromSuperViewOnHide = true //隐藏时从父视图中移除
//        hud.hide(animated: true, afterDelay: 2)  //2秒钟后自动隐藏
    }

    //自定义视图
    func test2() {
        //初始化HUD窗口，并置于当前的View当中显示
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "tick")!) //自定义视图显示图片
        hud.label.text = "操作成功"
    }
    

    func test3() {
        //显示成功消息
        MBProgressHUD.showSuccess("操作成功")
         
        //显示失败消息
        MBProgressHUD.showError("操作失败")
         
        //显示普通消息
        MBProgressHUD.showInfo("这是普通提示消息")
         
        //显示等待消息
        MBProgressHUD.showWait("请稍等")
        
        
        //显示成功消息
        self.view.showSuccess("操作成功")
         
        //显示失败消息
        self.view.showError("操作失败")
         
        //显示普通消息
        self.view.showInfo("这是普通提示消息")
         
        //显示等待消息
        self.view.showWait("请稍等")
    }
}

extension MBProgressHUD {
    //显示等待消息
    class func showWait(_ title: String) {
        let view = viewToShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
    }
     
    //显示普通消息
    class func showInfo(_ title: String) {
        let view = viewToShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "info")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
    }
     
    //显示成功消息
    class func showSuccess(_ title: String) {
        let view = viewToShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "tick")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
        //HUD窗口显示1秒后自动隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
 
    //显示失败消息
    class func showError(_ title: String) {
        let view = viewToShow()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "cross")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
        //HUD窗口显示1秒后自动隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
 
    //获取用于显示提示框的view
    class func viewToShow() -> UIView {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            let windowArray = UIApplication.shared.windows
            for tempWin in windowArray {
                if tempWin.windowLevel == UIWindow.Level.normal {
                    window = tempWin;
                    break
                }
            }
        }
        return window!
    }
}


extension UIView {
    //显示等待消息
    func showWait(_ title: String) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
    }
     
    //显示普通消息
    func showInfo(_ title: String) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "info")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
    }
     
    //显示成功消息
    func showSuccess(_ title: String) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "tick")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
        //HUD窗口显示1秒后自动隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
 
    //显示失败消息
    func showError(_ title: String) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .customView //模式设置为自定义视图
        hud.customView = UIImageView(image: UIImage(named: "cross")!) //自定义视图显示图片
        hud.label.text = title
        hud.removeFromSuperViewOnHide = true
        //HUD窗口显示1秒后自动隐藏
        hud.hide(animated: true, afterDelay: 1)
    }
}
