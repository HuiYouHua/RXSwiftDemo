//
//  ViewController3.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController3: UIViewController {
    var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    public lazy var refreshBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("刷新", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    public lazy var stopBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("停止", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "刷新表格数据"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: refreshBtn), UIBarButtonItem(customView: stopBtn)]
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        test1()
    }
    
    // MARK: - 数据刷新
    func test1() {
//        let randomResult = refreshBtn.rx.tap.asObservable()
//            .startWith(()) //加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest(getRandomResult) ///flatMapLatest 的作用是当在短时间内（上一个请求还没回来）连续点击多次“刷新”按钮，虽然仍会发起多次请求，但表格只会接收并显示最后一次请求。避免表格出现连续刷新的现象。
//            .share(replay: 1)
        
        ///也可以改用 flatMapFirst 来防止表格多次刷新，它与 flatMapLatest 刚好相反，如果连续发起多次请求，表格只会接收并显示第一次请求。
//        let randomResult = refreshButton.rx.tap.asObservable()
//            .startWith(()) //加这个为了让一开始就能自动请求一次数据
//            .flatMapFirst(getRandomResult)  //连续请求时只取第一次数据
//            .share(replay: 1)
        
        ///通过 throttle 设置个阀值（比如 1 秒），如果在1秒内有多次点击则只取最后一次，那么自然也就只发送一次数据请求
//        let randomResult = refreshButton.rx.tap.asObservable()
//            .throttle(1, scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
//            .startWith(()) //加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest(getRandomResult)
//            .share(replay: 1)
        
        let randomResult = refreshBtn.rx.tap.asObservable()
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest {
                ///通过 takeUntil 操作符实现。当 takeUntil 中的 Observable 发送一个值时，便会结束对应的 Observable
                self.getRandomResult().takeUntil(self.stopBtn.rx.tap)
            }
            .share(replay: 1)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>> { (dataSource, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
            return cell
        }
        
        randomResult.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据")
        let items = (0..<5).map{ _ in Int(arc4random()) }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    }


}
