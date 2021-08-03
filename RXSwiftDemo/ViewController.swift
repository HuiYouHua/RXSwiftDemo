//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/4/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let subject = PublishSubject<String>()
    let subject2 = PublishSubject<Any>()
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "")
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let subject1 = BehaviorSubject(value: "A")
//          let subject2 = BehaviorSubject(value: "1")
          let variable = Variable(subject1)
//
//          variable.asObservable()
//              .flatMapLatest { $0 }
//              .subscribe(onNext: { print($0) })
//              .disposed(by: disposeBag)
           
      
        
        variable.asObservable().flatMapFirst { $0 }.subscribe { (event) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                print("重新登录")
            }
            
        }.disposed(by: disposeBag)
        
        

    }

    private func demo1() {
        ///核心逻辑
        let observable = Observable<Any>.create { (anyObserver) -> Disposable in
            anyObserver.onNext("发送响应")
            anyObserver.onCompleted()
            return Disposables.create()
        }
        observable.subscribe { (text) in
            print("收到响应")
        }.disposed(by: disposeBag)
    }
    
    private func demo2() {
        ///ControlEvent
        /**
         btn.rx.controlEvent 内部封装了 类似demo1 的方法,并返回一个ControlEvent
         ControlEvent 中添加了一个方法, 点击事件产生后会调用该方法, 从而回到上面内部封装的回调中
         回调用发送 .on()方法, 再走核心逻辑, 回调到subscribe方法中
         */
        let ob = btn.rx.controlEvent(.touchUpInside)
        ob.subscribe { (reslut) in
            print("点击按钮·")
        }.disposed(by: disposeBag)
        
        btn.rx.tap
        .subscribe(onNext: { (event) in
            print("常用点击")
        }).disposed(by: disposeBag)
        
    }

    func demo3() {
        ///textFiled为何默认响应
        ///内部主动调用observer.on(.next(getter(control)))，就会来到外面的响应，执行默认响应：
        textFiled.rx.text
        .subscribe(onNext: { (text) in
             print("默认来第一次")
        }).disposed(by: disposeBag)
        
        textFiled.rx.text
        .skip(1)
        .subscribe(onNext: { (text) in
             print("跳过了第1次响应")
        }).disposed(by: disposeBag)
        
        textFiled.rx.text
        .changed
        .subscribe { (text) in
            print("常用监听输入，默认跳过第1次响应")
        }.disposed(by: disposeBag)
    }
    
    func demo4() {
        /**
         skip原理
        if self.remaining <= 0 {
            self.forwardOn(.next(value))
        }
        else {
            self.remaining -= 1
        }
         当remaining < 0 时才会发送信号
         */
        textFiled.rx.text
        .skip(1)
        .subscribe(onNext: { (text) in
             print("跳过了第1次响应")
        }).disposed(by: disposeBag)
    }
    
    func demo5() {
        ///bind
        /**
         textFiled.rx.text 是一个 ControlProperty
         label.rx.text 是一个 Binder
         bind(to:) 内部执行了subscribe方法, 同时调用了.on 方法
         也即 调用 Binder 的 .on() 方法
         /**
         self._binding = { event in
             switch event {
             case .next(let element):
                 _ = scheduler.schedule(element) { element in
                     if let target = weakTarget {
                         binding(target, element)
                     }
                     return Disposables.create()
                 }
             case .error(let error):
                 bindingError(error)
             case .completed:
                 break
             }
            }
         */
         binding(target, element) 闭包返回给 label.rx.text
         */
        textFiled.rx.text.bind(to: label.rx.text).disposed(by: disposeBag)
    }
    
    func demo6() {
        ///定时器
        ///内部封装的是 GCD 定时器 发送信号
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { e in
                print("定时器执行")
            }.disposed(by: disposeBag)
    }
    
    func demo7() {
        ///高阶函数
        /**
         func on(_ event: Event<SourceType>) {
             switch event {
             case .next(let element):
                 do {
                     let mappedElement = try self._transform(element)
                     self.forwardOn(.next(mappedElement))
                 }
                 catch let e {
                     self.forwardOn(.error(e))
                     self.dispose()
                 }
             case .error(let error):
                 self.forwardOn(.error(error))
                 self.dispose()
             case .completed:
                 self.forwardOn(.completed)
                 self.dispose()
             }
         }
         每次走到 on() 方法时,都会先走_transform()方法, 也就是.map 中的回调转换处理
         处理完毕后得到 mappedElement, 在进行信号的发送, 主要走的依然是核心逻辑
         */
        Observable.of(1,2,3)
        .map { (num) -> Int in
            return num+1
        }.subscribe { (num) in
            print(num)
        }.disposed(by: disposeBag)
    }
    
    func demo8() {
        ///combineLatest 有时候我们需要同时监听多个响应，或者合并多个响应时，就可以用combineLatest。
        /**
         func next(_ index: Int) {
             if !self._hasValue[index] {
                 self._hasValue[index] = true
                 self._numberOfValues += 1
             }

             if self._numberOfValues == self._arity {
                 do {
                     let result = try self.getResult()
                     self.forwardOn(.next(result))
                 }
                 catch let e {
                     self.forwardOn(.error(e))
                     self.dispose()
                 }
             }
             else {
                 var allOthersDone = true

                 for i in 0 ..< self._arity {
                     if i != index && !self._isDone[i] {
                         allOthersDone = false
                         break
                     }
                 }
                 
                 if allOthersDone {
                     self.forwardOn(.completed)
                     self.dispose()
                 }
             }
         }
         在这里进行记录每次信号的发出是否完成,并满足所有序列
         当 self._numberOfValues == self._arity 就表示所有的序列都发送完成了, 那么就可以回调到外部的订阅了
         
         combineLatest 表示最近的几个序列都有更新时, 则回调响应
         */
        let userNameVaild = textFiled.rx.text.orEmpty
        .map { (text) -> Bool in
             return text.count > 0
        }
        let passwordVaild = textFiled.rx.text.orEmpty
        .map { (text) -> Bool in
             return text.count > 0
        }
        Observable.combineLatest(userNameVaild,passwordVaild) { $0 && $1 }
        .bind(to: btn.rx.isEnabled)
        .disposed(by: disposeBag)
    }
    
    func demo9() {
        /**
         Driver: 如果我们的序列满足如下特征，就可以使⽤它:
         (1)不会产生 error 事件；
         (2)一定在主线程监听(MainScheduler)；
         (3)共享状态变化(shareReplayLatestWhileConnected)。
         内部也就是封装了上面的三个特性
         */
        
        func search(input: String)-> Observable<String> {
            return Observable<String>.create({ (observer) -> Disposable in
                DispatchQueue.global().async {
                    //假装在子线程进行了耗时的搜索
                    let result = "返回结果"
                    
                    observer.onNext(result)
                    observer.onCompleted()
                }
                return Disposables.create()
             })
        }
        
        let result = textFiled.rx.text.changed
                             .asDriver()
                             .flatMap {
                                  return search(input: $0!)
                                      .asDriver(onErrorJustReturn: "发生错误")
                              }
        result.drive(label.rx.text).disposed(by: disposeBag)
    }
    
    func demo10() {
        ///publish
        /**
         .publish 中的subscribe 中的 .on 方法会 返回一个 Observer, 而非以前的调用 方法的闭包, 因此当你调用 ob.subscribe() 时 并不会走到创建 Observable 的回调里
         而且当你调用 ob.subscribe() 时,内部会只创建一次被观察者, 节省内存和性能消耗 self.lazySubject.subscribe(observer)
         同时 当你 subscribe() 时, 它会将观察者加入一个数组中  let key = self._observers.insert(observer.on)
         为的是后面的publishSubject\behaviorSubject\replaySubject 的各种变形处理
         
         只有当你调用 .connect() 时 才会进行序列的订阅发送
         */
        let ob = Observable<Any>.create { (observer) -> Disposable in
            observer.onNext("连接后才订阅、发送和响应")
            observer.onCompleted()
            return Disposables.create()
        }.publish()  //注意
        ob.subscribe { (text) in
            print(text)
        }.disposed(by: disposeBag)
        _ = ob.connect()  //连接
    }
    
    @IBAction func click(_ sender: Any) {
        print("111")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
    }
    
}

