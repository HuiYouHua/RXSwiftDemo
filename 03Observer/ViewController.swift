//
//  ViewController.swift
//  03Observer
//
//  Created by 华惠友 on 2020/4/27.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
            
        /**
         观察者（Observer）的作用就是监听事件，然后对这个事件做出响应。或者说任何响应事件的行为都是观察者。比如：

         当我们点击按钮，弹出一个提示框。那么这个“弹出一个提示框”就是观察者Observer<Void>
         当我们请求一个远程的json 数据后，将其打印出来。那么这个“打印 json 数据”就是观察者 Observer<JSON>
         */
//        createObserver()
//        createAnyObserver()
//        createBindObserver()
        createSelfObserver()
    }
}

// MARK: - 在subscribe方法中创建
extension ViewController {
    func createObserver() {
        /**
        （1）创建观察者最直接的方法就是在 Observable 的 subscribe 方法后面描述当事件发生时，需要如何做出响应。

        （2）比如下面的样例，观察者就是由后面的 onNext，onError，onCompleted 这些闭包构建出来的。
        */
        let observable = Observable.of("A", "B", "C")
        
        observable.subscribe(onNext: { (element) in
            print(element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("complete")
        }) {
            print("dispose")
        }
        
        /**
         在 bind 方法中创建
         （1）下面代码我们创建一个定时生成索引数的 Observable 序列，并将索引数不断显示在 label 标签上
         */
        let observable1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        
        observable1.map {
            "当前索引数: \($0)"
        }.bind { [weak self] (text) in
            self?.label.text = text
        }.disposed(by: disposeBag)
        
    }

}

// MARK: - 使用AnyObserver创建观察者
extension ViewController {
    /// AnyObserver 可以用来描叙任意一种观察者。
    func createAnyObserver() {
        let observable: AnyObserver<String> = AnyObserver.init { (event) in
            switch event {
            case .next(let data):
                print(data)
            case .error(let error):
                print(error)
            case .completed:
                print("compelete")
            }
        }
        
        let observabel = Observable.of("A", "B", "C")
        observabel.subscribe(observable)
        
        
        // 配合 bindTo 方法使用
        // 也可配合 Observable 的数据绑定方法（bindTo）使用
        let observer1: AnyObserver<String> = AnyObserver.init { [weak self](event) in
            switch event {
            case .next(let text):
                self?.label.text = text
            default:
                break
            }
        }
        
        let observable1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable1.map {
            "当前索引数: \($0)"
        }.bind(to: observer1)
        .disposed(by: disposeBag)
        

    }
}

// MARK: - Bind
extension ViewController {
    func createBindObserver() {
        /**
         （1）相较于AnyObserver 的大而全，Binder 更专注于特定的场景。Binder 主要有以下两个特征：

         不会处理错误事件
         确保绑定都是在给定 Scheduler 上执行（默认 MainScheduler）
         （2）一旦产生错误事件，在调试环境下将执行 fatalError，在发布环境下将打印错误信息
         */
        let observer: Binder<String> = Binder.init(label) { (label, text) in
            label.text = text
        }
        
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable.map {
            "当前索引数: \($0)"
        }.bind(to: observer)
        .disposed(by: disposeBag)
    }
}

// MARK: - 自定义可绑定属性
extension ViewController {
    /// 有时我们想让 UI 控件创建出来后默认就有一些观察者，而不必每次都为它们单独去创建观察者。比如我们想要让所有的 UIlabel 都有个 fontSize 可绑定属性，它会根据事件值自动改变标签的字体大小
    func createSelfObserver() {
        //Observable序列（每隔0.5秒钟发出一个索引数）
        let observable = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance)
//        observable
//            .map { CGFloat($0) }
//            .bind(to: label.fontSize) //根据索引数不断变放大字体
//            .disposed(by: disposeBag)
        
//        observable
//        .map { CGFloat($0) }
//            .bind(to: label.rx.fontSize) //根据索引数不断变放大字体
//        .disposed(by: disposeBag)
        
    
        /// （1）其实 RxSwift 已经为我们提供许多常用的可绑定属性。比如 UILabel 就有 text 和 attributedText 这两个可绑定属性。
        observable
        .map { "当前索引数: \($0)" }
            .bind(to: label.rx.text) //根据索引数不断变放大字体
        .disposed(by: disposeBag)
    }

}

// 通过对 UI 类进行扩展
extension UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder.init(self) { (label, fontSize) in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}

// 通过对 Reactive 类进行扩展
/**
 既然使用了 RxSwift，那么更规范的写法应该是对 Reactive 进行扩展。这里同样是给 UILabel 增加了一个 fontSize 可绑定属性。

 （注意：这种方式下，我们绑定属性时要写成 label.rx.fontSize）
 */
extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder.init(self.base) { (label, fontSize) in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
