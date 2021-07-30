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

class ReactorKitController: UIViewController, StoryboardView {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    
    @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameOutlet.becomeFirstResponder()
        
        self.reactor = ViewReactor()
        
    }
    
    func bind(reactor: ViewReactor) {
        //Action（实现 View -> Reactor 的绑定）
        usernameOutlet.rx.text.orEmpty.changed  //用户名输入框文字改变事件
            .throttle(RxTimeInterval.milliseconds(50), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map(Reactor.Action.usernameChanged)  //转换为 Action.usernameChanged
            .bind(to: reactor.action)  //绑定到 reactor.action
            .disposed(by: disposeBag)
        
        passwordOutlet.rx.text.orEmpty.changed  //密码输入框文字改变事件
            .distinctUntilChanged()
            .map(Reactor.Action.passwordChanged)  //转换为 passwordChanged
            .bind(to: reactor.action)  //绑定到 reactor.action
            .disposed(by: disposeBag)
        
        repeatedPasswordOutlet.rx.text.orEmpty.changed  //重复密码输入框文字改变事件
            .distinctUntilChanged()
            .map(Reactor.Action.repeatedPasswordChanged)  //转换为 repeatedPasswordChanged
            .bind(to: reactor.action)  //绑定到 reactor.action
            .disposed(by: disposeBag)
        
        signupOutlet.rx.tap //注册按钮点击事件
            .map{ Reactor.Action.signup }  //转换为 signup
            .bind(to: reactor.action)  //绑定到 reactor.action
            .disposed(by: disposeBag)
        
        // State（实现 Reactor -> View 的绑定）
        reactor.state.map { $0.usernameValidationResult }  //得到最新用户名验证结果
        .bind(to: usernameValidationOutlet.rx.validResult)  //绑定到文本标签上
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.passwordValidationResult }  //得到最新密码验证结果
        .bind(to: passwordValidationOutlet.rx.validResult)  //绑定到文本标签上
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.repeatedPasswordValidationResult }  //得到最新重复密码验证结果
        .bind(to: repeatedPasswordValidationOutlet.rx.validResult)//绑定到文本标签上
        .disposed(by: disposeBag)
        
        //注册按钮是否可用
        reactor.state.map{ $0.usernameValidationResult.isValid &&
            $0.passwordValidationResult.isValid &&
            $0.repeatedPasswordValidationResult.isValid }
        .subscribe(onNext: { [weak self] valid in
            self?.signupOutlet.isEnabled = valid
            self?.signupOutlet.alpha = valid ? 1.0 : 0.3
        })
        .disposed(by: disposeBag)
        
        //活动指示器绑定
        reactor.state.map { $0.startSignup }
        .bind(to: signInActivityIndicator.rx.isAnimating)
        .disposed(by: disposeBag)
        
        //注册结果显示
        reactor.state.map { $0.signupResult }
        .filter{ $0 != nil }
        .subscribe(onNext: { [weak self] result in
            self?.showMessage("注册" + (result! ? "成功" : "失败") + "!")
        })
        .disposed(by: disposeBag)
    }
    
    //详细提示框
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: nil,
                                                message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

class ViewReactor: Reactor {
    //代表用户行为
    enum Action {
        case usernameChanged(String) //用户名输入
        case passwordChanged(String) //密码输入
        case repeatedPasswordChanged(String) //重复密码输入
        case signup //用户注册
    }
    
    //代表状态变化
    enum Mutation {
        case setUsername(String) //设置用户名
        case setUsernameValidationResult(ValidationResult) //设置用户名验证结果
        case setPassword(String) //设置密码
        case setPasswordValidationResult(ValidationResult) //设置用户名验证结果
        case setRepeatedPassword(String) //设置重复密码
        case setRepeatedPasswordValidationResult(ValidationResult) //设置重复密码验证结果
        case setStartSignup(Bool) //设置注册状态（是否正在提交注册）
        case setSignupResult(Bool?) //设置注册结果
    }
    
    //代表页面状态
    struct State {
        var username: String //用户名
        var password: String //密码
        var repeatedPassword: String //再出输入密码
        var usernameValidationResult: ValidationResult //用户名验证结果
        var passwordValidationResult: ValidationResult //密码验证结果
        var repeatedPasswordValidationResult: ValidationResult //重复密码验证结果
        var startSignup: Bool //开始注册
        var signupResult: Bool? //注册结果
    }
    
    let networkService = RactorNetworkService()
    let initialState: State
    
    init() {
        self.initialState = State(
            username: "",
            password: "",
            repeatedPassword: "",
            usernameValidationResult: ValidationResult.empty,
            passwordValidationResult: ValidationResult.empty,
            repeatedPasswordValidationResult: ValidationResult.empty,
            startSignup: false,
            signupResult: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .usernameChanged(let username):
            return Observable.concat([
                Observable.just(Mutation.setUsername(username)),
                networkService.usernameValidRequest(name: username)
                    .takeUntil(self.action.filter(isUsernameChangedAction))
                    .map(Mutation.setUsernameValidationResult)
            ])
        case .passwordChanged(let password):
            return Observable.concat([
                Observable.just(Mutation.setPassword(password)),
                Observable.just(Mutation.setPasswordValidationResult(networkService.passwordValidRequest(password: password))),
                Observable.just(Mutation.setRepeatedPasswordValidationResult(
                    networkService.repeatPasswordValidRequest(
                        password: password,
                        repeatPassword: self.currentState.repeatedPassword)
                ))
                
            ])
        case .repeatedPasswordChanged(let repeatPassword):
            return Observable.concat([
                Observable.just(Mutation.setRepeatedPassword(repeatPassword)),
                Observable.just(Mutation.setRepeatedPasswordValidationResult(
                    networkService.repeatPasswordValidRequest(
                        password: self.currentState.password,
                        repeatPassword: repeatPassword)))
            ])
        case .signup:
            return.concat([
                Observable.just(Mutation.setSignupResult(nil)),
                Observable.just(Mutation.setStartSignup(true)),
                networkService.signRequest(name: self.currentState.username, password: self.currentState.password)
                    .map{ $0.isValid }
                    .map(Mutation.setSignupResult),
                Observable.just(Mutation.setStartSignup(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setUsername(let username):
            state.username = username
            state.signupResult = nil
        case .setUsernameValidationResult(let validationResult):
            state.usernameValidationResult = validationResult
        case .setPassword(let password):
            state.password = password
            state.signupResult = nil
        case .setPasswordValidationResult(let validationResult):
            state.passwordValidationResult = validationResult
        case .setRepeatedPassword(let repeatPassword):
            state.repeatedPassword = repeatPassword
            state.signupResult = nil
        case .setRepeatedPasswordValidationResult(let validationResult):
            state.repeatedPasswordValidationResult = validationResult
        case .setStartSignup(let value):
            state.startSignup = value
        case .setSignupResult(let value):
            state.signupResult = value
            state.startSignup = false
        }
        return state
    }
    
    private func isUsernameChangedAction(_ action: Action) -> Bool {
        if case .usernameChanged = action {
            return true
        } else {
            return false
        }
    }
}

class RactorNetworkService {
    
    private var passwordMinLength = 5
    
    func usernameValidRequest(name: String) -> Observable<ValidationResult> {
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
        .startWith(.validating)
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
    
    func signRequest(name: String, password: String) -> Observable<ValidationResult> {
        return Observable.create { ob in
            ob.onNext(.ok(message: "注册成功"))
            return Disposables.create()
        }
        .delay(.milliseconds(2000), scheduler: MainScheduler.instance)///延迟测试
    }
}





