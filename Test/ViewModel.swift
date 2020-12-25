//
//  ViewModel.swift
//  Test
//
//  Created by 华惠友 on 2020/12/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewModel {
    let disposeBag = DisposeBag()
    
    // 查询是否有支付密码，带请求
    let checkPswInput = PublishRelay<Void>()
    
    // 处理查询结果
    let checkeNeedPswDispatch = PublishRelay<Bool>()
    
    // 去设置密码
    let gotoSetpswOutput = PublishRelay<Void>()
    
    // 弹出框输入密码
    let showSetpswOutput = PublishRelay<Void>()
    
    // 密码输入完成
    let setPswFinishInput = PublishRelay<String>()
    
    // all done
    let finishedAllOuput = PublishRelay<String>()
    
    init() {
        
        // flatMap后的内容其实应该用一个请求代替，这里简略一下直接把返回值标出来了
        // 一般Rx的请求返回的结果就是Observable<T>的
        checkPswInput
            .flatMap({ () -> Observable<Bool> in
                print("查询是否有支付密码，带请求")
                return Observable.just(true)
            })
            .bind(to: checkeNeedPswDispatch)
            .disposed(by: disposeBag)
        
        checkeNeedPswDispatch.subscribe(onNext: { (hasPsw) in
            if hasPsw {
                self.showSetpswOutput.accept(())
            }
            else {
                self.gotoSetpswOutput.accept(())
            }
        }).disposed(by: disposeBag)
        
        setPswFinishInput
            .flatMap { _ in Observable.just(true) }
            .map { _ in "Finishi" }.bind(to: finishedAllOuput)
            .disposed(by: disposeBag)
    }
}
