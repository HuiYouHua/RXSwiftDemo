//
//  ViewController.swift
//  19UI控件扩展3：UIButton、UIBarButtonItem
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        button.rx.tap.bind { [weak self] in
            self?.showMessage("按钮被点击")
        }
        .disposed(by: disposeBag)

        let timer = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        timer.map{ "计时\($0)" }
        .bind(to: button.rx.title(for: .normal))
        .disposed(by: disposeBag)
        
        
        let buttons = [button, button, button].map { $0! }
        let btns = Observable.from(
            buttons.map({ (buttonss) in
                buttonss.rx.tap.map{ buttonss }
            })
        )
        
        let ss = button.rx.tap.flatMap{ Observable.just(self.button) }
        
    }
    //显示消息提示框
    func showMessage(_ text: String) {
        let alertController = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

//// MARK: -
//extension ViewController {
//    //
//    func () {
//
//    }
//}

