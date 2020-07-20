//
//  ViewController.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/4/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    let subject = PublishSubject<String>()
    let subject2 = PublishSubject<Any>()
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "")
    
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

    @IBAction func click(_ sender: Any) {
        print("111")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
        subject1.onNext("")
    }
    
}

