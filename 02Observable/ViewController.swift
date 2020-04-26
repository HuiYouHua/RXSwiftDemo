//
//  ViewController.swift
//  02Observable
//
//  Created by 华惠友 on 2020/4/26.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

//        subscribe()
        doOn()
    }
    
}

// MARK: - 创建可被观察Observable对象
/**
 Observable<T> 这个类就是Rx 框架的基础，我们可以称它为可观察序列。它的作用就是可以异步地产生一系列的 Event（事件），即一个 Observable<T> 对象会随着时间推移不定期地发出 event(element : T) 这样一个东西。
 而且这些 Event 还可以携带数据，它的泛型 <T> 就是用来指定这个Event携带的数据的类型。
 有了
 */
extension ViewController {
    func just() {
        /// 该方法通过传入一个默认值来初始化
        /// 显式地标注出了 observable 的类型为 Observable<Int>，即指定了这个 Observable所发出的事件携带的数据类型必须是 Int 类型的
        let observable = Observable<Int>.just(5)
    }
    
    func of() {
        /// 该方法可以接受可变数量的参数（必需要是同类型的）
        /// 没有显式地声明出 Observable 的泛型类型，Swift 也会自动推断类型
        let observable = Observable.of("A", "B", "C")
    }

    func from() {
        /// 该方法需要一个数组参数
        /// 数据里的元素就会被当做这个 Observable 所发出 event携带的数据内容，最终效果同上面的 of()样例是一样的
        let observable = Observable.from(["A", "B", "C"])
    }

    func empty() {
        /// 创建一个空内容的 Observable 序列
        let observable = Observable<Int>.empty()
    }
    
    func never() {
        /// 创建一个永远不会发出 Event（也不会终止）的 Observable 序列
        let observable = Observable<Int>.never()
    }
    
    enum MyError: Error {
        case A
        case B
    }
    func error() {
        /// 该方法创建一个不做任何操作，而是直接发送一个错误的 Observable 序列
        let observable = Observable<Int>.error(MyError.A)
        let mye = MyError.A
    }
    
    func range() {
        /// 该方法通过指定起始和结束数值，创建一个以这个范围内所有值作为初始值的Observable序列。
        /// 两种方法创建的 Observable 序列都是一样的
        let observable1 = Observable.range(start: 1, count: 5)
        let observable2 = Observable.of(1, 2, 3, 4, 5)
    }
    
    func repeatElement() {
        /// 该方法创建一个可以无限发出给定元素的 Event的 Observable 序列（永不终止）
        let observable = Observable.repeatElement(1)
    }
    
    func generate() {
        /// 该方法创建一个只有当提供的所有的判断条件都为 true 的时候，才会给出动作的 Observable 序列
        /// 两种方法创建的 Observable 序列都是一样的
        let observable1 = Observable.generate(initialState: 0, condition: { (ele) -> Bool in
            ele <= 10
        }) { (ele) -> Int in
            ele + 2
        }
        
        let observable2 = Observable.generate(initialState: 0, condition: {$0 <= 10 }, iterate: { $0 + 2 })
        let observable3 = Observable.of(0, 2, 4, 6, 8, 10)
    }
    
    func create() {
        /// 该方法接受一个 block 形式的参数，任务是对每一个过来的订阅进行处理
        //这个block有一个回调参数observer就是订阅这个Observable对象的订阅者
        //当一个订阅者订阅这个Observable对象的时候，就会将订阅者作为参数传入这个block来执行一些内容
        let observable = Observable<String>.create{observer in
            //对订阅者发出了.next事件，且携带了一个数据"hangge.com"
            observer.onNext("hangge.com")
            //对订阅者发出了.completed事件
            observer.onCompleted()
        
            //因为一个订阅行为会有一个Disposable类型的返回值，所以在结尾一定要returen一个Disposable
            return Disposables.create()
        }
         
        //订阅测试
        observable.subscribe {
            print($0)
        }
    }
    
    func deferred() {
        /// 该个方法相当于是创建一个 Observable 工厂，通过传入一个 block 来执行延迟 Observable序列创建的行为，而这个 block 里就是真正的实例化序列对象的地方
        //用于标记是奇数、还是偶数
        var isOdd = true
    //使用deferred()方法延迟Observable序列的初始化，通过传入的block来实现Observable序列的初始化并且返回。
        let factory : Observable<Int> = Observable.deferred {
            //让每次执行这个block时候都会让奇、偶数进行交替
            isOdd = !isOdd
             
            //根据isOdd参数，决定创建并返回的是奇数Observable、还是偶数Observable
            if isOdd {
                return Observable.of(1, 3, 5 ,7)
            }else {
                return Observable.of(2, 4, 6, 8)
            }
        }
         
        //第1次订阅测试
        factory.subscribe { event in
            print("\(isOdd)", event)
        }
         
        //第2次订阅测试
        factory.subscribe { event in
            print("\(isOdd)", event)
        }
    }
    
    func interval() {
        /// 这个方法创建的 Observable 序列每隔一段设定的时间，会发出一个索引数的元素。而且它会一直发送下去
        /// 让其每 1 秒发送一次，并且是在主线程（MainScheduler）发送
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable.subscribe { (event) in
            print(event)
        }
    }
    
    func timer() {
        /// 这个方法有两种用法，一种是创建的 Observable序列在经过设定的一段时间后，产生唯一的一个元素
        /// 5秒种后发出唯一的一个元素0
        let observable1 = Observable<Int>.timer(5, scheduler: MainScheduler.instance)
        observable1.subscribe { (event) in
            print(event)
        }
        
        let observable2 = Observable<Int>.timer(5, period: 1, scheduler: MainScheduler.instance)
        observable2.subscribe { (event) in
            print(event)
        }
    }
}

// MARK: - 订阅Observable
/**
 有了 Observable，我们还要使用 subscribe() 方法来订阅它，接收它发出的 Event
 */
extension ViewController {
    func subscribe() {
        let observable = Observable.of("A", "B", "C")
        
        // 第一种用法：
        // 我们使用 subscribe() 订阅了一个Observable 对象，该方法的 block 的回调参数就是被发出的 event 事件，我们将其直接打印出来
        // 初始化 Observable 序列时设置的默认值都按顺序通过 .next 事件发送出来。
        // 当 Observable 序列的初始数据都发送完毕，它还会自动发一个 .completed 事件出来
        // 如果想要获取到这个事件里的数据，可以通过 event.element 得到
        observable.subscribe { (event) in
            print(event)
            print(event.element)
        }
        
        // 第二种用法：
        // RxSwift 还提供了另一个 subscribe方法，它可以把 event 进行分类：
        // 通过不同的 block 回调处理不同类型的 event。（其中 onDisposed 表示订阅行为被 dispose 后的回调，这个我后面会说）
        // 同时会把 event 携带的数据直接解包出来作为参数，方便我们使用
        observable.subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("complete")
        }) {
            print("dispose")
        }
        
        // subscribe() 方法的 onNext、onError、onCompleted 和 onDisposed 这四个回调 block 参数都是有默认值的，即它们都是可选的。所以我们也可以只处理 onNext而不管其他的情况
        observable.subscribe(onNext: { (element) in
            print(element)
        })
    }
}

// MARK: - 监听事件的生命周期
/**
 我们可以使用 doOn 方法来监听事件的生命周期，它会在每一次事件发送前被调用。
 同时它和 subscribe 一样，可以通过不同的block 回调处理不同类型的 event。比如：

 do(onNext:)方法就是在subscribe(onNext:) 前调用
 而 do(onCompleted:) 方法则会在 subscribe(onCompleted:) 前面调用
 */
extension ViewController {
    func doOn() {
        let observable = Observable.of("A", "B", "C")
        observable.do(onNext: { (element) in
            print("do onNext: " + element)
        }, afterNext: { (element) in
            print("afterNext: " + element)
        }, onError: { (error) in
            print(error)
        }, afterError: { (error) in
            print(error)
        }, onCompleted: {
            print("onCompleted")
        }, afterCompleted: {
            print("afterCompleted")
        }, onSubscribe: {
            print("onSubscribe")
        }, onSubscribed: {
            print("onSubscribed")
        }) {
            print("on dispose")
        }
        
        .subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("complete")
        }) {
            print("dispose")
        }
    }
}

// MARK: - Observable的销毁
extension ViewController {
    /**
     1.一个 Observable 序列被创建出来后它不会马上就开始被激活从而发出 Event，而是要等到它被某个人订阅了才会激活它。
     2.而 Observable 序列激活之后要一直等到它发出了.error或者 .completed的 event 后，它才被终结
     */
    
    /**
     dispose()方法
     1.使用该方法我们可以手动取消一个订阅行为。
     2.如果我们觉得这个订阅结束了不再需要了，就可以调用dispose()方法把这个订阅给销毁掉，防止内存泄漏。
     3.当一个订阅行为被dispose 了，那么之后 observable 如果再发出 event，这个已经 dispose 的订阅就收不到消息了
     */
    func dispose() {
        let observable = Observable.of("A", "B", "C")
                 
        //使用subscription常量存储这个订阅方法
        let subscription = observable.subscribe { event in
            print(event)
        }
                 
        //调用这个订阅的dispose()方法
        subscription.dispose()
    }
    
    /**
     DisposeBag
     除了 dispose()方法之外，我们更经常用到的是一个叫 DisposeBag 的对象来管理多个订阅行为的销毁：
     我们可以把一个 DisposeBag对象看成一个垃圾袋，把用过的订阅行为都放进去。
     而这个DisposeBag 就会在自己快要dealloc 的时候，对它里面的所有订阅行为都调用 dispose()方法
     */
    func disposeBag() {
        let disposeBag = DisposeBag()
                 
        //第1个Observable，及其订阅
        let observable1 = Observable.of("A", "B", "C")
        observable1.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
         
        //第2个Observable，及其订阅
        let observable2 = Observable.of(1, 2, 3)
        observable2.subscribe { event in
            print(event)
        }.disposed(by: disposeBag)
    }
}
