//
//  ViewController.swift
//  05变换操作符buffer、map、compactMap、scan
//
//  Created by 华惠友 on 2020/4/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// 变换操作指的是对原始的 Observable 序列进行一些转换，类似于 Swift 中 CollectionType 的各种转换。
class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        buffer()
        window()
    }
}

// MARK: - buffer
extension ViewController {
    /**
     buffer 方法作用是缓冲组合，第一个参数是缓冲时间，第二个参数是缓冲个数，第三个参数是线程。
     该方法简单来说就是缓存 Observable 中发出的新元素，当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来
     */
    func buffer() {
        let subject = PublishSubject<String>()
        
        // 每缓存3个元素则组合起来一起发出
        // 如果1秒钟内不够3个也会发出(有几个发几个, 一个都没有发空数组)
        subject.buffer(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
         
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
    }
}

// MARK: - window
extension ViewController {
    /**
     window 操作符和 buffer 十分相似。不过 buffer 是周期性的将缓存的元素集合发送出来，而 window 周期性的将元素集合以 Observable 的形态发送出来。
     同时 buffer要等到元素搜集完毕后，才会发出元素序列。而 window 可以实时发出元素序列。
     */
    func window() {
        let subject = PublishSubject<String>()
        
        // 每3个元素作为一个子Observable发出
        subject.window(timeSpan: 1, count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                print($0)
                $0.asObservable()
                .subscribe(onNext: { print("asObservable  " + $0) })
                    .disposed(by: self!.disposeBag)
            }).disposed(by: disposeBag)
        
        subject.onNext("a")
        subject.onNext("b")
        subject.onNext("c")
         
        subject.onNext("1")
        subject.onNext("2")
        subject.onNext("3")
    }
}
