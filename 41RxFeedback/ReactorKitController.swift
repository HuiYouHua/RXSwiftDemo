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
        
        /**
         1，整体架构
         （1）使用 ReactorKit 架构后代码根据职能分为 View（视图）和 Reactor（响应器）两部分：
         View 是用户直接操作的层级，我们通过监测用户在 View 上的行为，转化成 Action 反馈给 Reactor。
         Reactor 处理之后又把响应状态 State 传递给 View 层，View 这边显示最终的传递的状态。

         （2）简单来说就是 View 层只发出行为，而 Reactor 只发出状态，相互把对方所需要的东西传递给对方，构成一条响应式的序列。
         
         2，Reactor 代码结构
         （1）Reactor 是与 UI 相互独立的一层，它的作用就是将业务逻辑从 View 中抽离。也就是说每一个 View 都有对应的 Reactor ，并且将所有的逻辑代理都较给 Reactor（Reactor 接收到 View 层发出的 Action，然后通过内部操作，将 Action 转换为 State。）

         （2）定义一个 Reactor 需要遵守 Reactor 协议，该协议定义了如下内容：
         四个响应属性：Action、Mutation、State、initialState。
         两个响应方法：mutate()、reduce()

         （3）这些响应属性和响应方法的作用，以及相互关系如下：
         Action：描述用户行为
         Mutation：描述状态变更（ 它可以看作是 Action 到 State 的桥梁）
         State：描述当前状态
         initialState：描述初始化状态
         mutate()：处理 Action 执行一些业务逻辑，并转换为 Mutation。
         reduce()： 通过旧的 State 以及 Mutation 创建一个新的 State。
         
         3，View 代码结构
         （1）View 为数据展示层，不管是 UIViewController 还是 UIView 都可以看作是 View。View 主要负责发出 Action，同时将 State 绑定到 UI 组件上。

         （2）定义一个 View 只需要让它遵循 ReactorKit 的 View 或 StoryboardView 协议即可：
         如果 ViewController 是纯代码开发的：则其遵守 View 协议。
         如果 ViewController 是 Storyboard 开发的：则其遵守 StoryboardView 协议。

         （3）View 中需要定义如下内容：
         disposeBag 属性：协议属性。当 View 的 reactor 变化时，之前的 disposeBag 会自动 disposed。
         bind(reactor:) 方法：实现用户输入绑定和状态输出绑定。

         （4）协议中的 bind() 方法不需要我们手动去调用。遵循 View 协的类将自动获得一个 reactor 属性。当 View 的 reactor 属性被设置时，bind() 方法就会被自动调用。

         原文出自：www.hangge.com  转载请保留原文链接：https://www.hangge.com/blog/cache/detail_2040.html
         */
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





