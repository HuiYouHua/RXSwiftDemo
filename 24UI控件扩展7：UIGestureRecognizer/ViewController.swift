//
//  ViewController.swift
//  24UI控件扩展7：UIGestureRecognizer
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加一个上滑手势
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        self.view.addGestureRecognizer(swipe)
        
        swipe.rx.event.bind { [weak self] recognizer in
            //这个点是滑动的起点
            let point = recognizer.location(in: recognizer.view)
            self?.showAlert(title: "向上划动", message: "\(point.x) \(point.y)")
        }
        .disposed(by: disposeBag)
        
        
        view.rx.tapGesture().when(.recognized).subscribe(onNext: { [weak self] _ in
            print("123")
        }).disposed(by: disposeBag)
    }
        
    //显示消息提示框
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .cancel))
        self.present(alert, animated: true)
    }
    
}
