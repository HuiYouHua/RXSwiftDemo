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
    var collectionView:UICollectionView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "UICollectionView的使用2：RxDataSources"
        
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        flowLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 40)
        
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
        
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        //创建一个重用的分区头
        self.collectionView.register(MySectionHeader.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "Section")
        self.view.addSubview(self.collectionView!)
        
        //        test1()
        //        test2()
        test3()
    }
    
    
    //MARK: - 使用自带的Sction
    func test1() {
        //初始化数据
        let items = Observable.just([
            SectionModel(model: "", items: [
                "Swift",
                "PHP",
                "Python",
                "Java",
                "javascript",
                "C#"
            ])
        ])
        
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource
        <SectionModel<String, String>>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                              for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell}
        )
        
        //绑定单元格数据
        items
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    //MARK: - 使用自定义的Sction
    func test2() {
        //初始化数据
        let sections = Observable.just([
            MySection(header: "", items: [
                "Swift",
                "PHP",
                "Python",
                "Java",
                "javascript",
                "C#"
            ])
        ])
        
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource<MySection>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                              for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell}
        )
        
        //绑定单元格数据
        sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    //MARK: - 多分区的CollectionView
    func test3() {
        //初始化数据
        let sections = Observable.just([
            MySection(header: "脚本语言", items: [
                "Python",
                "javascript",
                "PHP",
            ]),
            MySection(header: "高级语言", items: [
                "Swift",
                "C++",
                "Java",
                "C#"
            ])
        ])
        
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource<MySection>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                              for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell},
            configureSupplementaryView: {
                (ds ,cv, kind, ip) in
                let section = cv.dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseIdentifier: "Section", for: ip) as! MySectionHeader
                section.label.text = "\(ds[ip.section].header)"
                return section
            })
        
        //绑定单元格数据
        sections
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}


//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = String
    
    var identity: String {
        return header
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}
