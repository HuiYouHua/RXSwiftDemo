//
//  ViewController4.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class ViewController4: UIViewController {
    var tableView: UITableView!
    var searchBar:UISearchBar!
    let disposeBag = DisposeBag()
    public lazy var refreshBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("刷新", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "UITableView的使用4：表格数据的搜索过滤"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: refreshBtn)]

        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        //创建表头的搜索栏
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                            width: self.view.bounds.size.width, height: 56))
        self.tableView.tableHeaderView =  self.searchBar
        
        test1()
    }
    
    // MARK: -
    func test1() {
        let randomResult = refreshBtn.rx.tap.asObservable()
            .startWith(())
            .flatMapLatest(getRandomResult)
            .flatMap(filterResult)
            .share(replay: 1)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Int>> { (dataSource, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
            return cell
        }
        
        randomResult.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("请求数据")
        let items = (0..<5).map { _ in
            Int(arc4random())
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    }
    
    ///过滤
    func filterResult(data: [SectionModel<String, Int>]) -> Observable<[SectionModel<String, Int>]> {
        return self.searchBar.rx.text.orEmpty
            .debounce(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMapLatest { query -> Observable<[SectionModel<String, Int>]> in
                print("正在筛选数据（条件为：\(query)）")
                if query.isEmpty {
                    return Observable.just(data)
                }
                var newData: [SectionModel<String, Int>] = []
                for sectionModel in data {
                    let items = sectionModel.items.filter({ "\($0)".contains(query) })
                    newData.append(SectionModel(model: sectionModel.model, items: items))
                }
                return Observable.just(newData)
            }

    }

}
