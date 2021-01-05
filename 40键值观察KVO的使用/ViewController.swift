//
//  ViewController.swift
//  40键值观察KVO的使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
 
class ViewController: UIViewController {
     
    let disposeBag = DisposeBag()
     
    @objc dynamic var message = "hangge.com"
     
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //定时器（1秒执行一次）
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                //每次给字符串尾部添加一个感叹号
                self.message.append("!")
            }).disposed(by: disposeBag)
         
        //监听message变量的变化
        _ = self.rx.observeWeakly(String.self, "message")
            .subscribe(onNext: { (value) in
            print(value ?? "")
        })
        
        //监听视图frame的变化
                _ = self.rx.observe(CGRect.self, "view.frame")
                    .subscribe(onNext: { frame in
                        print("--- 视图尺寸发生变化 ---")
                        print(frame!)
                        print("\n")
                    })
    }


}

