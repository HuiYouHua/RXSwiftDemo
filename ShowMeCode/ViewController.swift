//
//  ViewController.swift
//  ShowMeCode
//
//  Created by 华惠友 on 2021/1/5.
//  Copyright © 2021 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - starWith\flatMapLatest\flatMapFirst\map\flatMap
    func test1() {
        let btn = UIButton()
        btn.rx.tap.asObservable()
            .throttle(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            //            .flatMapLatest(getRandomResult) //连续请求时只取最后一次数据
            //            .flatMapFirst(getRandomResult)  //连续请求时只取第一次数据
            .flatMapLatest{
                ///当按钮点击 结束Observable
                self.getRandomResult().takeUntil(btn.rx.tap)
            }
            .flatMap(filterResult) //筛选数据
            .map({ $0.map({ $0 * 10 }) }) //进行转换
            .distinctUntilChanged() //过滤掉连续重复
            .take(2) //仅发送前两个数据
            .takeLast(2) //仅发送后两个数据
            .skip(2) //跳过前两个数据
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)// 只发出与下一个间隔超过0.5秒的元素
            .share(replay: 1)
        
        /**
         //第一个请求
         let userRequest: Observable<User> = API.getUser("me")
         
         //第二个请求
         let friendsRequest: Observable<Friends> = API.getFriends("me")
         
         //将两个请求合并处理
         zip 常常用在整合网络请求上。
         比如我们想同时发送两个请求，只有当两个请求都成功后，再将两者的结果整合起来继续往下处理。这个功能就可以通过 zip 来实现。
         Observable.zip(userRequest, friendsRequest) {
         user, friends in
         //将两个信号合并成一个信号，并压缩成一个元组返回（两个信号均成功）
         return (user, friends)
         }
         .observeOn(MainScheduler.instance) //加这个是应为请求在后台线程，下面的绑定在前台线程。
         .subscribe(onNext: { (user, friends) in
         //将数据绑定到界面上
         //.......
         })
         .disposed(by: disposeBag)
         */
        //该方法可以将多个（两个或两个以上的）Observable 序列压缩成一个 Observable 序列。而且它会等到每个 Observable 事件一一对应地凑齐之后再合并。
        Observable.zip(getRandomResult(), getRandomResult1())
            .subscribe { (e) in
                print(e.element?.0)
                print(e.element?.1)
            }.disposed(by: disposeBag)
        
        
        ///该方法同样是将多个（两个或两个以上的）Observable 序列元素进行合并。但与 zip 不同的是，每当任意一个 Observable 有新的事件发出时，它会将每个 Observable 序列的最新的一个事件元素进行合并。
        Observable.combineLatest(getRandomResult(), getRandomResult1())
            .subscribe { (e) in
                print(e.element?.0)
                print(e.element?.1)
            }.disposed(by: disposeBag)
        
        
        Observable.of(getRandomResult(), getRandomResult1())
            .merge()///该方法可以将多个（两个或两个以上的）Observable 序列合并成一个 Observable 序列。
            .subscribe { (e) in
                print(e.element ?? [])
            }.disposed(by: disposeBag)
        
        
        ///该方法将两个 Observable 序列合并为一个。每当 self 队列发射一个元素时，便从第二个序列中取出最新的一个值。
        getRandomResult().withLatestFrom(getRandomResult1())
            .subscribe { (e) in
                print(e.element ?? [])
            }.disposed(by: disposeBag)
    }
    
    ///检测当前值与初始值是否相同：isEqualOriginValue
    func test2() {
        Observable.of("a", "b", "c", "a", "e")
            .isEqualOriginValue()
            .subscribe(onNext: {
                print("当前值是：\($0.value)", "是否与除初始值相同：\($0.isEqualOriginValue)" )
            })
            .disposed(by: disposeBag)
    }
    
    ///重复执行某个操作序列：repeatWhen
    func test3() {
        let refreshButton = UIButton()
        //创建URL对象
        //创建URL对象
        let urlString = "http://douban.fm/j/mine/playlist?type=n&channel=1&from=mainsite"
        let url = URL(string:urlString)
        //创建请求对象
        let request = URLRequest(url: url!)
        
        //创建并发起请求
        URLSession.shared.rx.data(request: request)
            .repeatWhen(refreshButton.rx.tap) //刷新按钮点击后再次请求
            .subscribe(onNext: {
                data in
                let json = try! JSONSerialization.jsonObject(with: data,
                                                             options: JSONSerialization.ReadingOptions.mutableContainers)
                    as! [String: Any]
                let song = (json["song"] as! [[String: Any]])[0]
                let artist = song["artist"] as! String
                let title = song["title"] as! String
            }).disposed(by: disposeBag)
    }
    
    //获取随机数据
    func getRandomResult() -> Observable<[Int]> {
        print("正在请求数据......")
        let items: [Int] = (0 ..< 5).map {_ in
            Int(arc4random())
        }
        return Observable.just(items)
    }
    func getRandomResult1() -> Observable<[Int]> {
        print("正在请求数据......")
        let items: [Int] = (0 ..< 5).map {_ in
            Int(arc4random())
        }
        return Observable.just(items)
    }
    
    //过滤数据
    func filterResult(data:[Int]) -> Observable<[Int]> {
        return Observable.just(data.filter({ $0 > 10 }))
    }
}

///检测当前值与初始值是否相同：isEqualOriginValue
///scan用法
extension ObservableConvertibleType where Element: Equatable {
    
    //将原始序列（当前值）转换成（当前值, 是否与最初值相同）的序列
    func isEqualOriginValue() -> Observable<(value: Element, isEqualOriginValue: Bool)> {
        return self.asObservable()
            .scan(nil){ acum, x -> (origin: Element, current: Element)? in
                if let acum = acum {
                    return (origin: acum.origin, current: x)
                } else {
                    return (origin: x, current: x)
                }
            }
            .map { ($0!.current, isEqualOriginValue: $0!.origin == $0!.current) }
    }
}

///重复执行某个操作序列：repeatWhen
extension ObservableConvertibleType {
    
    //当被监视的序列（notifier）发出事件时，重新发送源序列
    func repeatWhen<O: ObservableType>(_ notifier: O) -> Observable<Element> {
        return notifier.map { _ in }
            .startWith(())
            .flatMap { () -> Observable<Element> in
                self.asObservable()
            }
    }
}

