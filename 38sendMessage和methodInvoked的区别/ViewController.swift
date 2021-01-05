//
//  ViewController.swift
//  38sendMessage和methodInvoked的区别
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /**
         sentMessage 方法也有同样的作用，它们间只有一个区别：
         sentMessage 会在调用方法前发送值。
         methodInvoked 会在调用方法后发送值。
         */
        
        //使用sentMessage方法获取Observable
        self.rx.sentMessage(#selector(ViewController.viewWillAppear(_:)))
            .subscribe(onNext: { value in
                print("1")
            })
            .disposed(by: disposeBag)
        
        //使用methodInvoked方法获取Observable
        self.rx.methodInvoked(#selector(ViewController.viewWillAppear(_:)))
            .subscribe(onNext: { value in
                print("3")
            })
            .disposed(by: disposeBag)
    }
    
    //默认的viewWillAppear方法
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("2")
    }
    
    
}

