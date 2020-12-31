//
//  ViewController.swift
//  31结合RxAlamofire使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import RxAlamofire
import Alamofire

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    public lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("发起请求", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 84, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    public lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消请求", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 84, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: startBtn), UIBarButtonItem(customView: cancelBtn)]
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
         
        //创建并发起请求
        request(.get, url)
            .data()
            .subscribe(onNext: {
                data in
                //数据处理
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("返回的数据是：", str ?? "")
            }).disposed(by: disposeBag)
    }


}

