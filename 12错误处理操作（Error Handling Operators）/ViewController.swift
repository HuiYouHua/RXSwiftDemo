//
//  ViewController.swift
//  12错误处理操作（Error Handling Operators）
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
    case A
    case B
}

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - catchErrorJustReturn
extension ViewController {
    //
    func catchErrorJustReturn() {
         
        let sequenceThatFails = PublishSubject<String>()
         
        sequenceThatFails
            .catchErrorJustReturn("错误")
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")
    }
}

// MARK: - catchError
extension ViewController {
    // 该方法可以捕获 error，并对其进行处理。
    // 同时还能返回另一个 Observable 序列进行订阅（切换到新的序列
    func catchError() {
        let sequenceThatFails = PublishSubject<String>()
        let recoverySequence = Observable.of("1", "2", "3")
         
        sequenceThatFails
            .catchError {
                print("Error:", $0)
                return recoverySequence
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        sequenceThatFails.onNext("a")
        sequenceThatFails.onNext("b")
        sequenceThatFails.onNext("c")
        sequenceThatFails.onError(MyError.A)
        sequenceThatFails.onNext("d")
    }
}

// MARK: - retry
extension ViewController {
    // 使用该方法当遇到错误的时候，会重新订阅该序列。比如遇到网络请求失败时，可以进行重新连接。
    // retry() 方法可以传入数字表示重试次数。不传的话只会重试一次
    func retry() {
        var count = 1
         
        let sequenceThatErrors = Observable<String>.create { observer in
            observer.onNext("a")
            observer.onNext("b")
             
            //让第一个订阅时发生错误
            if count == 1 {
                observer.onError(MyError.A)
                print("Error encountered")
                count += 1
            }
             
            observer.onNext("c")
            observer.onNext("d")
            observer.onCompleted()
             
            return Disposables.create()
        }
         
        sequenceThatErrors
            .retry(2)  //重试2次（参数为空则只重试一次）
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
    }
}
