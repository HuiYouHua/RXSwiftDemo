//
//  ViewController.swift
//  34SwiftNotice使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func test1() {
        //显示等待提示框
        SwiftNotice.wait()

        //显示等待提示框
                self.pleaseWait()
        
        //方法1
        SwiftNotice.showText("请稍等")
         
        //方法2
        self.noticeOnlyText("请稍等")
        
        //显示后不自动隐藏
        SwiftNotice.showText("请稍等", autoClear: false)
                 
        //显示后过个1秒钟自动隐藏
        SwiftNotice.showText("请稍等", autoClearTime: 1)

        //方法1
        SwiftNotice.showNoticeWithText(.success, text: "操作成功", autoClear: true, autoClearTime: 2)
                 
        //方法2
        self.noticeSuccess("操作成功", autoClear: true, autoClearTime: 2)

        //方法1
        SwiftNotice.showNoticeWithText(.error, text: "操作失败", autoClear: true, autoClearTime: 2)
                 
        //方法2
        self.noticeError("操作失败", autoClear: true, autoClearTime: 2)

        //方法1
        SwiftNotice.showNoticeWithText(.info, text: "普通消息", autoClear: true, autoClearTime: 2)
                 
        //方法2
        self.noticeInfo("普通消息", autoClear: true, autoClearTime: 2)

        //方法1
        SwiftNotice.clear()
                 
        //方法2
        self.clearAllNotice()

    }
    
    func test2() {
        ///顶部状态栏消息
        //方法1
        SwiftNotice.noticeOnStatusBar("这是一条通知消息", autoClear: true, autoClearTime: 2)
                 
        //方法2
        self.noticeTop("这是一条通知消息", autoClear: true, autoClearTime: 2)

        
        ///动画
        //准备好图片数组
        var images = [UIImage]()
        for i in 1..<74 {
            images.append(UIImage(named: "frame_apngframe\(i)")!)
        }
         
        //方法1
        SwiftNotice.wait(images, timeInterval: 50) //每隔50毫秒切换一张图片
                 
        //方法2
        self.pleaseWaitWithImages(images, timeInterval: 50) //每隔50毫秒切换一张图片

        原文出自：www.hangge.com  转载请保留原文链接：https://www.hangge.com/blog/cache/detail_2033.html
    }
}

