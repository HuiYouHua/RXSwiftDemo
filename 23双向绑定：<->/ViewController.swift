//
//  ViewController.swift
//  23双向绑定：<->
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    var userModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 将username绑定到textField上,显示guest
        userModel.username.asObservable().bind(to: textField.rx.text).disposed(by: disposeBag)
        // 将textField绑定到username上, textField变化,那么username也会变化
        textField.rx.text.orEmpty.bind(to: userModel.username).disposed(by: disposeBag)
        
        _ =  self.textField.rx.textInput <-> self.userModel.username
        
        // 将userinfo绑定到label上, userinfo变化,那么label也会变化
        userModel.userinfo.bind(to: label.rx.text).disposed(by: disposeBag)

    }
}

struct UserViewModel {
    let username = Variable("guest")
    let name = "guest"
    lazy var userinfo = {
        return self.username.asObservable()
            .map{ $0 == "huayoyu" ? "您是管理员" : "您是普通访客" }
            .share(replay: 1)
    }()
}
