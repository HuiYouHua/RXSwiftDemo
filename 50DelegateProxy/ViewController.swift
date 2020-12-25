//
//  ViewController.swift
//  50DelegateProxy
//
//  Created by 华惠友 on 2020/11/17.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //应用重新回到活动状态
        UIApplication.shared.rx
            .didBecomeActive
            .subscribe(onNext: { _ in
                print("应用进入活动状态。")
            })
            .disposed(by: disposeBag)
        
        //应用从活动状态进入非活动状态
        UIApplication.shared.rx
            .willResignActive
            .subscribe(onNext: { _ in
                print("应用从活动状态进入非活动状态。")
            })
            .disposed(by: disposeBag)
        
        //应用从后台恢复至前台（还不是活动状态）
        UIApplication.shared.rx
            .willEnterForeground
            .subscribe(onNext: { _ in
                print("应用从后台恢复至前台（还不是活动状态）。")
            })
            .disposed(by: disposeBag)
        
        //应用进入到后台
        UIApplication.shared.rx
            .didEnterBackground
            .subscribe(onNext: { _ in
                print("应用进入到后台。")
            })
            .disposed(by: disposeBag)
        
        //应用终止
        UIApplication.shared.rx
            .willTerminate
            .subscribe(onNext: { _ in
                print("应用终止。")
            })
            .disposed(by: disposeBag)
        
        //应用重新回到活动状态
        UIApplication.shared.rx
            .state
            .subscribe(onNext: { state in
                switch state {
                case .active:
                    print("应用进入活动状态。")
                case .inactive:
                    print("应用进入非活动状态。")
                case .background:
                    print("应用进入到后台。")
                case .terminated:
                    print("应用终止。")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
}

