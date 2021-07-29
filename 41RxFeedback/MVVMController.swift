//
//  MVVMController.swift
//  41RxFeedback
//
//  Created by 华惠友 on 2021/7/28.
//  Copyright © 2021 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MVVMController: UIViewController {

    
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    
    @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    private var networkService = NetworkService()
    
    private var viewModel: ViewModel!
    /**
     默认“注册”按钮不可用，只有用户名、密码、再次输入密码三者都符合如下条件时才可用：
     输入用户名时会同步检查该用户名是否符合条件（只能为数字或字母），以及是否已存在（通过网络请求），并在输入框下方显示验证结果。
     输入密码时会检查密码是否符合条件（最少要 5 位），并在输入框下方显示验证结果。
     再次输入密码时会检查两个密码是否一致，并在输入框下方显示验证结果。
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameOutlet.becomeFirstResponder()
        
        let nameValidAction = usernameOutlet.rx.text.orEmpty.asDriver().debounce(.milliseconds(50))
        let pswValidAction = passwordOutlet.rx.text.orEmpty.asDriver().debounce(.milliseconds(50))
        let repeatPswValidAction = repeatedPasswordOutlet.rx.text.orEmpty.asDriver().debounce(.milliseconds(50))
        let signTapAction = signupOutlet.rx.tap.asSignal()
        
        viewModel = ViewModel(
            nameValidAction: nameValidAction,
            pswValidAction: pswValidAction,
            repeatPswValidAction: repeatPswValidAction,
            signTapAction: signTapAction,
            networkService: networkService)
        
        viewModel.nameResult
            .drive(usernameValidationOutlet.rx.validResult)
            .disposed(by: disposeBag)
        
        viewModel.pswResult
            .drive(passwordValidationOutlet.rx.validResult)
            .disposed(by: disposeBag)
        
        viewModel.repeatPswResult
            .drive(repeatedPasswordValidationOutlet.rx.validResult)
            .disposed(by: disposeBag)
        
        viewModel.signEnableResult
            .drive(signupOutlet.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.signResult
            .drive { result in
                switch result {
                case .ok(let msg):
                    let alertController = UIAlertController(title: nil,
                                                                    message: msg, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        viewModel.signResult
            .map{ $0.isIndicicator }
            .drive(signInActivityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
    }
}

fileprivate class ViewModel {
    
    ///用户名验证结果
    var nameResult: Driver<ValidationResult>
    ///密码验证结果
    var pswResult: Driver<ValidationResult>
    ///确认密码验证结果
    var repeatPswResult: Driver<ValidationResult>
    ///注册按钮是否可点击结果
    var signEnableResult: Driver<Bool>
    ///注册结果
    var signResult: Driver<ValidationResult>
    
    init(nameValidAction: Driver<String>,
         pswValidAction: Driver<String>,
         repeatPswValidAction: Driver<String>,
         signTapAction: Signal<Void>,
         networkService: NetworkService) {
        
        nameResult = nameValidAction
            .flatMapLatest(networkService.usernameValidRequest)
        
        pswResult = pswValidAction
            .map(networkService.passwordValidRequest)
        
        repeatPswResult = Driver.combineLatest(pswValidAction, repeatPswValidAction)
            .map(networkService.repeatPasswordValidRequest)
        
        signEnableResult = Driver.combineLatest(nameResult, pswResult, repeatPswResult)
            .map{ $0.0.isValid && $0.1.isValid && $0.2.isValid }
        
        signResult = signTapAction
            .withLatestFrom(Driver.combineLatest(nameValidAction, pswValidAction))
            .flatMapLatest(networkService.signRequest)
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

public extension Reactive where Base: UILabel {
    var validResult: Binder<ValidationResult> {
        return Binder(base) { lable, result in
            lable.text = result.description
            lable.textColor = result.textColor
        }
    }
}

public enum ValidationResult {
    case validating  //正在验证中s
    case empty  //输入为空
    case ok(message: String) //验证通过
    case failed(message: String)  //验证失败
}
 
public extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    var isIndicicator: Bool {
        switch self {
        case .validating:
            return true
        default:
            return false
        }
    }
}
 
extension ValidationResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .validating:
            return "正在验证..."
        case .empty:
            return ""
        case let .ok(message):
            return message
        case let .failed(message):
            return message
        }
    }
}
 
public extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .validating:
            return UIColor.gray
        case .empty:
            return UIColor.black
        case .ok:
            return UIColor(red: 0/255, green: 130/255, blue: 0/255, alpha: 1)
        case .failed:
            return UIColor.red
        }
    }
}
