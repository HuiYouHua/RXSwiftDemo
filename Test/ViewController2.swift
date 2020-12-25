//
//  ViewController2.swift
//  Test
//
//  Created by 华惠友 on 2020/12/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController2: UIViewController {
    let disposeBag = DisposeBag()
    
    let viewModel = ViewModel2()
    
    private lazy var tableView: UITableView = {
        let t = UITableView()
        return t
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        view.addSubview(tableView)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        
        
        //创建数据源
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "\(ip.row)：\(item)"
                
                return cell
            },
            //设置分区头标题
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
            }
        )
        
        //绑定单元格数据
        viewModel.sectionableData()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        //        viewModel
        //                .sectionableData().asObservable()
        //                .bind(to: tableView, by: { (_, _, _, item) -> UITableViewCell in
        //                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        //                    cell?.textLabel?.text = item.name
        //                    return cell!
        //                }).disposed(by: disposeBag)
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
