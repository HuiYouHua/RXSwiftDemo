//
//  ViewController.swift
//  18UI控件扩展2：UITextField、UITextView
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        //创建文本输入框
            let inputField = UITextField(frame: CGRect(x:10, y:80, width:200, height:30))
        inputField.borderStyle = .roundedRect
            self.view.addSubview(inputField)
             
            //创建文本输出框
            let outputField = UITextField(frame: CGRect(x:10, y:150, width:200, height:30))
            outputField.borderStyle = .roundedRect
            self.view.addSubview(outputField)
             
            //创建文本标签
            let label = UILabel(frame:CGRect(x:20, y:190, width:300, height:30))
            self.view.addSubview(label)
             
            //创建按钮
            let button:UIButton = UIButton(type:.system)
            button.frame = CGRect(x:20, y:230, width:40, height:30)
            button.setTitle("提交", for:.normal)
            self.view.addSubview(button)
             
             
            //当文本框内容改变
            let input = inputField.rx.text.orEmpty.asDriver() // 将普通序列转换为 Driver
                .throttle(0.3) //在主线程中操作，0.3秒内值若多次改变，取最后一次
             
            //内容绑定到另一个输入框中
            input.drive(outputField.rx.text)
                .disposed(by: disposeBag)
             
            //内容绑定到文本标签中
            input.map{ "当前字数：\($0.count)" }
                .drive(label.rx.text)
                .disposed(by: disposeBag)
             
            //根据内容字数决定按钮是否可用
            input.map{ $0.count > 5 }
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)
        
        inputField.rx.controlEvent([.editingDidBegin]) //状态可以组合
        .asObservable()
        .subscribe(onNext: { _ in
            print("开始编辑内容!")
        }).disposed(by: disposeBag)
       
    }
}

// MARK: -
//extension ViewController {
//    //
//    func () {
//
//    }
//}
