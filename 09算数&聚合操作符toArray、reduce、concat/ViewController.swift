//
//  ViewController.swift
//  09算数&聚合操作符toArray、reduce、concat
//
//  Created by 华惠友 on 2020/4/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - toArray
extension ViewController {
    // 该操作符先把一个序列转成一个数组，并作为一个单一的事件发送，然后结束
    func toArray() {
        Observable.of(1, 2, 3)
        .toArray()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    }
}

// MARK: - reduce
extension ViewController {
    /**
     reduce 接受一个初始值，和一个操作符号。
     reduce 将给定的初始值，与序列里的每个值进行累计运算。得到一个最终结果，并将其作为单个值发送出去
     */
    func reduce() {
        Observable.of(1, 2, 3, 4, 5)
        .reduce(0, accumulator: +)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    }
}

// MARK: - concat
extension ViewController {
    /**
     concat 会把多个 Observable 序列合并（串联）为一个 Observable 序列。
     并且只有当前面一个 Observable 序列发出了 completed 事件，才会开始发送下一个 Observable 序列事件
     */
    func concat() {
        let subject1 = BehaviorSubject(value: 1)
        let subject2 = BehaviorSubject(value: 2)
         
        let variable = Variable(subject1)
        variable.asObservable()
            .concat()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject2.onNext(2)
        subject1.onNext(1)
        subject1.onNext(1)
        subject1.onCompleted()
         
        variable.value = subject2
        subject2.onNext(2)
    }
}


