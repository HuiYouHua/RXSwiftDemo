//
//  ViewController5.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class ViewController5: UIViewController {
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
    public lazy var addBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("添加", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "UITableView的使用5：可编辑表格"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: refreshBtn), UIBarButtonItem(customView: addBtn)]
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        //创建表头的搜索栏
        self.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0,
                                                   width: self.view.bounds.size.width, height: 56))
        self.tableView.tableHeaderView =  self.searchBar
        
        //表格模型
        let initalVM = TableViewModel()
        
        //刷新数据命令
        let refreshCommand = refreshBtn.rx.tap.asObservable()
            .startWith(())
            .flatMapLatest(getRandomResult)
            .map(TableEditingCommand.setItems)
        
        //新增条目命令
        let addCommand = addBtn.rx.tap.asObservable()
            .map{ "\(arc4random())" }
            .map(TableEditingCommand.addItem)
        
        //移动位置命令
        let movedCommand = tableView.rx.itemMoved
            .map(TableEditingCommand.moveItem)
        
        //删除条目命令
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableEditingCommand.deleteItem)
        
        ///绑定单元格数据
        Observable.of(refreshCommand, addCommand, movedCommand, deleteCommand)
            .merge()
            .scan(initalVM) { (vm: TableViewModel, command: TableEditingCommand) -> TableViewModel in
                return vm.execute(command: command)
            }
            .startWith(initalVM)
            .map {
                [AnimatableSectionModel(model: "", items: $0.items)]
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: ViewController.dataSource()))
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.setEditing(true, animated: true)
    }
    
    func getRandomResult() -> Observable<[String]> {
        print("请求数据")
        let items = (0..<5).map { _ in
            "\(arc4random())"
        }
        return Observable.just(items)
    }
}

extension ViewController {
    //创建表格数据源
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource
    <AnimatableSectionModel<String, String>> {
        return RxTableViewSectionedAnimatedDataSource(
            //设置插入、删除、移动单元格的动画效果
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: {
                (dataSource, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
            },
            canEditRowAtIndexPath: { _, _ in
                return true //单元格可删除
            },
            canMoveRowAtIndexPath: { _, _ in
                return true //单元格可移动
            }
        )
    }
}

//定义各种操作命令
enum TableEditingCommand {
    case setItems(items: [String])  //设置表格数据
    case addItem(item: String)  //新增数据
    case moveItem(from: IndexPath, to: IndexPath) //移动数据
    case deleteItem(IndexPath) //删除数据
}

//定义表格对应的ViewModel
struct TableViewModel {
    //表格数据项
    fileprivate var items:[String]
    
    init(items: [String] = []) {
        self.items = items
    }
    
    //执行相应的命令，并返回最终的结果
    func execute(command: TableEditingCommand) -> TableViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据。")
            return TableViewModel(items: items)
        case .addItem(let item):
            print("新增数据项。")
            var items = self.items
            items.append(item)
            return TableViewModel(items: items)
        case .moveItem(let from, let to):
            print("移动数据项。")
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return TableViewModel(items: items)
        case .deleteItem(let indexPath):
            print("删除数据项。")
            var items = self.items
            items.remove(at: indexPath.row)
            return TableViewModel(items: items)
        }
    }
}
