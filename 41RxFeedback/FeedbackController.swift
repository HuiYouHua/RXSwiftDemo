//
//  FeedbackController.swift
//  41RxFeedback
//
//  Created by 华惠友 on 2021/7/28.
//  Copyright © 2021 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

class FeedbackController: UIViewController {
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
        
        /**
         RxFeedback 的核心内容为状态（State）、事件（Event）、反馈循环（Feedback Loop）：
         State：包含页面中各种需要的数据。我们可以用这些状态来控制页面内容的显示，或者触发另外一个事件。
         Event：用来描述所产生的事件。当发生某个事件时，更新当前状态。
         Feedback Loop：用来修改状态、IO 和资源管理的。比如我们可以将状态输出到 UI 页面上，或者将 UI 事件输入到反馈循环里面去。
         */
        let networkService = NetworkService()
        
        let bindUI: (Driver<SignState>) -> Signal<SignEvent> =
            bind(self) { me, state in
            //状态输出到页面控件上
            let subscriptions = [
                state.map{ $0.usernameValidationResult }
                    .drive(me.usernameValidationOutlet.rx.validResult),
                state.map{ $0.passwordValidationResult }
                    .drive(me.passwordValidationOutlet.rx.validResult),
                state.map{ $0.repeatedPasswordValidationResult }
                    .drive(me.repeatedPasswordValidationOutlet.rx.validResult),
                state.map{ $0.usernameValidationResult.isValid && $0.passwordValidationResult.isValid && $0.repeatedPasswordValidationResult.isValid }
                    .drive(me.signupOutlet.rx.isEnabled),
                state.map{ $0.startSignup }
                    .drive(me.signInActivityIndicator.rx.isAnimating),
                state.map{ $0.signupResult }
                    .filter{ $0 != nil }
                    .drive(onNext: { result in
                        let msg = result! ? "注册成功" : "注册失败"
                        let alertController = UIAlertController(title: nil,
                                                                        message: msg, preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                    })
            ]
            
            let events = [
                me.usernameOutlet.rx.text.orEmpty.skip(1).asSignal(onErrorJustReturn: "").debounce(.milliseconds(50))
                    .map(SignEvent.usernameChanged),
                me.passwordOutlet.rx.text.orEmpty.skip(1).asSignal(onErrorJustReturn: "").debounce(.milliseconds(50))
                    .map(SignEvent.passwordChanged),
                me.repeatedPasswordOutlet.rx.text.orEmpty.skip(1).asSignal(onErrorJustReturn: "").debounce(.milliseconds(50))
                    .map(SignEvent.repeatedPasswordChanged),
                me.signupOutlet.rx.tap
                    .asSignal().map{_ in SignEvent.signup}
            ]
            return Bindings(subscriptions: subscriptions, events: events)
        }
        
        Driver.system(
                    //初始状态
                    initialState: SignState.empty,
                    //各个事件对状态的改变
                    reduce: { SignState.reduce(state: $0, event: $1,
                                               networkService: networkService) },
                    feedback:
                        //UI反馈
                        bindUI,
                        //非UI的自动反馈（用户名验证）
            SignFeedback.validateUsernameReact(networkService: networkService),
                        //非UI的自动反馈（用户注册）
            SignFeedback.validateSignupReact(networkService: networkService)
                    )
                    .drive()
                    .disposed(by: disposeBag)
        
    }
}


///状态
fileprivate struct SignState {
    var username: String? //用户名
    var password: String? //密码
    var repeatedPassword: String? //再出输入密码
    var usernameValidationResult: ValidationResult //用户名验证结果
    var passwordValidationResult: ValidationResult //密码验证结果
    var repeatedPasswordValidationResult: ValidationResult //重复密码验证结果
    var startSignup: Bool //开始注册
    var signupResult: Bool? //注册结果
     
    //用户注册信息（只有开始注册状态下才有数据返回）
    var signupData: SignInfo? {
        return startSignup ? SignInfo(username: username ?? "", password: password ?? "") : nil
    }
}

struct SignInfo: Equatable {
    var username: String
    var password: String
}


///事件
fileprivate enum SignEvent {
    case usernameChanged(String) //用户名输入
    case passwordChanged(String) //密码输入
    case repeatedPasswordChanged(String) //重复密码输入
    case usernameValidated(ValidationResult) //用户名验证结束
    case signup //用户注册
    case signupResponse(Bool) //注册响应
}

fileprivate extension SignState {
    static var empty: SignState {
        return SignState(
            username: nil,
            password: nil,
            repeatedPassword: nil,
            usernameValidationResult: .empty,
            passwordValidationResult: .empty,
            repeatedPasswordValidationResult: .empty,
            startSignup: false,
            signupResult: nil
        )
    }
    
    static func reduce(
        state: SignState,
        event: SignEvent,
        networkService: NetworkService
    ) -> SignState {
        switch event {
        case .usernameChanged(let value):
            var result = state
            result.username = value
            result.signupResult = nil
            return result
        case .passwordChanged(let value):
            var result = state
            result.password = value
            result.passwordValidationResult = networkService.passwordValidRequest(password: result.password ?? "")
            ///验证密码重复输入
            if let repeatPassword = result.repeatedPassword {
                result.repeatedPasswordValidationResult = networkService.repeatPasswordValidRequest(password: result.password ?? "", repeatPassword: repeatPassword)
            }
            result.signupResult = nil
            return result
        case .repeatedPasswordChanged(let value):
            var result = state
            result.repeatedPassword = value
            result.repeatedPasswordValidationResult = networkService.repeatPasswordValidRequest(password: result.password ?? "", repeatPassword: result.repeatedPassword ?? "")
            result.signupResult = nil
            return result
        case .usernameValidated(let value):
            var result = state
            result.usernameValidationResult = value
            result.signupResult = nil
            return result
        case .signup:
            var result = state
            result.startSignup = true
            result.signupResult = nil
            return result
        case .signupResponse(let value):
            var result = state
            result.startSignup = false
            result.signupResult = value
            return result
        }
    }
}

///与 UI 无关的反馈
fileprivate struct SignFeedback {
    //验证用户名
    static func validateUsernameReact(networkService: NetworkService) -> (Driver<SignState>) -> Signal<SignEvent> {
        return react { $0.username }
            effects: {
                networkService.usernameValidRequest(name: $0)
                    .asSignal(onErrorRecover: { _ in .empty() })
                    .map(SignEvent.usernameValidated)
            }
    }
    
    ///用户注册
    static func validateSignupReact(networkService: NetworkService) -> (Driver<SignState>) -> Signal<SignEvent> {
        return react { $0.signupData }
            effects: {
                networkService.signRequest(name: $0.username, password: $0.password)
                    .map{ $0.isValid }
                    .asSignal(onErrorRecover: { _ in .empty() })
                    .map(SignEvent.signupResponse)
            }
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
//        .startWith(.validating)///发起网络请求之前先返回一个正在验证的结果
    }
}

