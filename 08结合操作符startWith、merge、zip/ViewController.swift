//
//  ViewController.swift
//  08结合操作符startWith、merge、zip
//
//  Created by 华惠友 on 2020/4/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    // 结合操作（或者称合并操作）指的是将多个 Observable 序列进行组合，拼装成一个新的 Observable 序列
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// MARK: - startWith
extension ViewController {
    // 该方法会在 Observable 序列开始之前插入一些事件元素。即发出事件消息之前，会先发出这些预先插入的事件消息
    func startWith() {
        Observable.of("2", "3")
        .startWith("1")
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
        
        Observable.of("2", "3")
        .startWith("a")
        .startWith("b")
        .startWith("c")
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    }
}

// MARK: - merge
extension ViewController {
    // 该方法可以将多个（两个或两个以上的）Observable 序列合并成一个 Observable序列。
    func merge() {
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<Int>()
         
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject1.onNext(20)
        subject1.onNext(40)
        subject1.onNext(60)
        subject2.onNext(1)
        subject1.onNext(80)
        subject1.onNext(100)
        subject2.onNext(1)
    }
}

// MARK: - zip
extension ViewController {
    // 该方法可以将多个（两个或两个以上的）Observable 序列压缩成一个 Observable 序列。
    // 而且它会等到每个 Observable 事件一一对应地凑齐之后再合并
    func zip() {
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
         
        Observable.zip(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
    }
}

// MARK: - combineLatest
extension ViewController {
    /**
     该方法同样是将多个（两个或两个以上的）Observable 序列元素进行合并。
     但与 zip 不同的是，每当任意一个 Observable 有新的事件发出时，它会将每个 Observable 序列的最新的一个事件元素进行合并
     */
    func combineLatest() {
        let subject1 = PublishSubject<Int>()
        let subject2 = PublishSubject<String>()
         
        Observable.combineLatest(subject1, subject2) {
            "\($0)\($1)"
            }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject1.onNext(1)
        subject2.onNext("A")
        subject1.onNext(2)
        subject2.onNext("B")
        subject2.onNext("C")
        subject2.onNext("D")
        subject1.onNext(3)
        subject1.onNext(4)
        subject1.onNext(5)
    }
}

// MARK: - withLatestFrom
extension ViewController {
    // 该方法将两个 Observable 序列合并为一个。每当 self 队列发射一个元素时，便从第二个序列中取出最新的一个值
    func withLatestFrom() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
         
        subject1.withLatestFrom(subject2)
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject1.onNext("A")
        subject2.onNext("1")
        subject1.onNext("B")
        subject1.onNext("C")
        subject2.onNext("2")
        subject1.onNext("D")
    }
}

// MARK: - switchLatest
extension ViewController {
    // switchLatest 有点像其他语言的switch 方法，可以对事件流进行转换。
    // 比如本来监听的 subject1，我可以通过更改 variable 里面的 value 更换事件源。变成监听 subject2
    func switchLatest() {
        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "1")
         
        let variable = Variable(subject1)
         
        variable.asObservable()
            .switchLatest()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
         
        subject1.onNext("B")
        subject1.onNext("C")
         
        //改变事件源
        variable.value = subject2
        subject1.onNext("D")
        subject2.onNext("2")
         
        //改变事件源
        variable.value = subject1
        subject2.onNext("3")
        subject1.onNext("E")
    }
}

