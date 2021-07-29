//
//  ReactorKitController.swift
//  41RxFeedback
//
//  Created by 华惠友 on 2021/7/28.
//  Copyright © 2021 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

class ReactorKitController: UIViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    
    @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameOutlet.becomeFirstResponder()

    }


}

fileprivate class NetworkService {
    
    private var passwordMinLength = 5
    
    func usernameValidRequest(name: String) -> Driver<ValidationResult> {
        if name.isEmpty {
            return .just(.empty)
        }
        if name.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "用户名只能包含数字和字母"))
        }
        
        return Observable.create { ob in
             if name == "huayoyu" {
                ob.onNext(.ok(message: "用户名可用"))
            } else {
                ob.onNext(.failed(message: "用户名不可用"))
            }
            return Disposables.create()
        }
        .delay(.milliseconds(1000), scheduler: MainScheduler.instance)///延迟测试
        .asDriver(onErrorDriveWith: .just(.failed(message: "请求错误")))
        .startWith(.validating) ///发起网络请求之前先返回一个正在验证的结果
    }
    
    func passwordValidRequest(password: String) -> ValidationResult {
        if password.isEmpty {
            return .empty
        }
        if password.count <= self.passwordMinLength {
            return .failed(message: "密码长度不够")
        }
        return .ok(message: "密码有效")
    }
    
    func repeatPasswordValidRequest(password: String, repeatPassword: String) -> ValidationResult {
        if repeatPassword.isEmpty {
            return .empty
        }
        if password == repeatPassword {
            return .ok(message: "密码校验准")
        }
        return .failed(message: "两次输入的密码不一致")
    }
    
    func signRequest(name: String, password: String) -> Driver<ValidationResult> {
        return Observable.create { ob in
            ob.onNext(.ok(message: "注册成功"))
            return Disposables.create()
        }
        .delay(.milliseconds(2000), scheduler: MainScheduler.instance)///延迟测试
        .asDriver(onErrorDriveWith: .empty())
        .startWith(.validating)///发起网络请求之前先返回一个正在验证的结果
    }
}




 
