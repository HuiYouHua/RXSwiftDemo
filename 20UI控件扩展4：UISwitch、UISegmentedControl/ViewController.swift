//
//  ViewController.swift
//  20UI控件扩展4：UISwitch、UISegmentedControl
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let switch1 = UISwitch()
        let button1 = UIButton()
        switch1.rx.isOn.subscribe(onNext: {print("当前开关状态：\($0)")})
        .disposed(by: disposeBag)
        
        switch1.rx.isOn
        .bind(to: button1.rx.isEnabled)
        .disposed(by: disposeBag)
    }
    
}

// MARK: -
//extension ViewController {
//    //
//    func () {
//        
//    }
//}
