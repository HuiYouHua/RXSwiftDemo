//
//  ViewController7.swift
//  RXSwiftDemo
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController7: UIViewController {
    var tableView: UITableView!
    let disposeBag = DisposeBag()
    var dataSource:RxTableViewSectionedAnimatedDataSource<MySection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "UITableView的使用7：样式修改"
        
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        //初始化数据
        let sections = Observable.just([
            MySection(header: "基本控件", items: [
                MySectionItem(name: "UILable的用法", age: "12"),
                MySectionItem(name: "UIText的用法", age: "14"),
                MySectionItem(name: "UIButton的用法", age: "16")
            ]),
            MySection(header: "高级控件", items: [
                MySectionItem(name: "UILable的用法", age: "12"),
                MySectionItem(name: "UIText的用法", age: "14"),
                MySectionItem(name: "UIButton的用法", age: "16")
            ])
        ])
        
        //创建数据源
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "\(ip.row)：\(item.name) - \(item.age)"
                return cell
            },
            //设置分区尾部标题
            titleForFooterInSection: { ds, index in
                return "共有\(ds.sectionModels[index].items.count)个控件"
            }
        )
        
        self.dataSource = dataSource
        
        //绑定单元格数据
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //设置代理
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
}

//tableView代理实现
extension ViewController7 : UITableViewDelegate {
    //设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
    -> CGFloat {
        guard let _ = dataSource?[indexPath],
              let _ = dataSource?[indexPath.section]
        else {
            return 0.0
        }
        
        return 60
    }
    
    //返回分区头部视图
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
    -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.black
        let titleLabel = UILabel()
        titleLabel.text = self.dataSource?[section].header
        titleLabel.textColor = UIColor.white
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.width/2, y: 20)
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    //返回分区头部高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
    -> CGFloat {
        return 40
    }
}
