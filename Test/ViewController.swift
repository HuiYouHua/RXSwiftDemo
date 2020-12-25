//
//  ViewController.swift
//  Test
//
//  Created by 华惠友 on 2020/12/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    @IBOutlet weak var button: UIButton!
    // 按钮点击
    let buttonTapOutput = PublishRelay<Void>()
    
    // 跳转去设置支付密码
    let gotoSetpswInput = PublishRelay<Void>()
    
    // 弹密码输入框
    let showSetpswInput = PublishRelay<Void>()
    
    // 输入密码完成
    let finishedSettingpswOutput = PublishRelay<String>()
    
    // 流程完成
    let allFinishedInput = PublishRelay<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.rx.tap
            .bind(to: buttonTapOutput)
            .disposed(by: disposeBag)
        
        gotoSetpswInput.subscribe(onNext: { (_) in
            // 此处添加navigate跳转逻辑
            print("跳转啦啦啦")
            
        }).disposed(by: disposeBag)
        
        showSetpswInput.subscribe(onNext: { (_) in
            // 此处添加弹出密码设置
            print("设置密码啦啦啦")
            
        }).disposed(by: disposeBag)
        
        allFinishedInput.subscribe(onNext: { (_) in
            print("all done")
            
        }).disposed(by: disposeBag)
        
        
        // Controller <=> ViewModel 绑定
        buttonTapOutput
            .bind(to: viewModel.checkPswInput)
            .disposed(by: disposeBag)
        
        finishedSettingpswOutput
            .bind(to: viewModel.setPswFinishInput)
            .disposed(by: disposeBag)
        
        viewModel.gotoSetpswOutput.bind(to: gotoSetpswInput).disposed(by: disposeBag)
        viewModel.showSetpswOutput.bind(to: showSetpswInput).disposed(by: disposeBag)
        viewModel.finishedAllOuput.bind(to: allFinishedInput).disposed(by: disposeBag)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.present(ViewController2(), animated: true, completion: nil)
    }
}

