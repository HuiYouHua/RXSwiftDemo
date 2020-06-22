//
//  ViewController.swift
//  26UITableView的使用1：基本用法
//
//  Created by 华惠友 on 2020/5/7.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView(frame: view.frame, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        let items = Observable.just([
        "文本输入框的用法",
        "开关按钮的用法",
        "进度条的用法",
        "文本标签的用法"
        ])
     
        let bind = items.bind(to: tableView.rx.items)
        bind

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self](indexPath) in
                switch indexPath.item {
                case 0:
                    self?.navigationController?.pushViewController(RxDataSourceTableViewController(), animated: true)
                default:
                    break
                }
            })
        .disposed(by: disposeBag)
        
    
    }
}


