//
//  ViewController2.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController2: UIViewController {

    var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "UITableView的使用2：RxDataSources"
        
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
//        test1()
//        test2()
        test3()
    }
    
    // MARK: - 使用自带的section
    func test1() {
        ///初始化数据
        let items = Observable.just([
            SectionModel(model: "", items: [
                MyModel(name: "UILable的用法", age: "12"),
                MyModel(name: "UIText的用法", age: "14"),
                MyModel(name: "UIButton的用法", age: "16")
            ])
        ])
        
        ///创建数据源
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MyModel>> { (dataSource, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(indexPath.row)：\(element.name) - \(element.age)"
            return cell
        }
        
        ///绑定单元格数据
        items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    // MARK: - 使用自定义的Section
    func test2() {
        let items = Observable.just([
            MySection(header: "", items: [
                MySectionItem(name: "UILable的用法", age: "12"),
                MySectionItem(name: "UIText的用法", age: "14"),
                MySectionItem(name: "UIButton的用法", age: "16")
                ])
            ])
        
        let dataSource = RxTableViewSectionedReloadDataSource<MySection> { (dataSource, tv, indexPath, element) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(indexPath.row)：\(element.name) - \(element.age)"
            return cell
        }
        items.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }

    // MARK: - 多分区的tableView
    func test3() {
        //初始化数据
                let items = Observable.just([
                    SectionModel(model: "基本控件", items: [
                        "UILable的用法",
                        "UIText的用法",
                        "UIButton的用法"
                        ]),
                    SectionModel(model: "高级控件", items: [
                        "UITableView的用法",
                        "UICollectionViews的用法"
                        ])
                    ])
                 
                //创建数据源
                let dataSource = RxTableViewSectionedReloadDataSource
                    <SectionModel<String, String>>(configureCell: {
                    (dataSource, tv, indexPath, element) in
                    let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                    cell.textLabel?.text = "\(indexPath.row)：\(element)"
                    return cell
                }) { (dataSource, index) -> String? in
                    //设置分区头标题
                    return dataSource.sectionModels[index].model
                }
                 
//                //设置分区头标题
//                dataSource.titleForHeaderInSection = { ds, index in
//
//                }
                 
                //设置分区尾标题
                //dataSource.titleForFooterInSection = { ds, index in
                //    return "footer"
                //}
                 
                //绑定单元格数据
                items
                    .bind(to: tableView.rx.items(dataSource: dataSource))
                    .disposed(by: disposeBag)
    }
}

///自带的Section中的item
struct MyModel {
    var name: String
    var age: String
}



///自定义的Section中的Item
struct MySectionItem: IdentifiableType, Equatable {
    var name: String
    var age: String
    
    typealias Identity = String
    var identity: String {
        return name
    }
}


///自定义的Section
struct MySection: AnimatableSectionModelType {
    var header: String
    var items: [Item]
    
    typealias Item = MySectionItem
    
    var identity: String {
        return header
    }
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}
