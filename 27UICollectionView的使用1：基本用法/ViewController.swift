//
//  ViewController.swift
//  37UICollectionView的使用1：基本用法
//
//  Created by 华惠友 on 2020/6/22.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    
    
    var collectionView:UICollectionView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 70)
        
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
        
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView!)
        
        //初始化数据
        let items = Observable.just([
            "UICollectionView的使用2：RxDataSources",
            "UICollectionView的使用3：刷新集合数据",
            "UICollectionView的使用4：样式修改"
        ])
        
        //设置单元格数据（其实就是对 cellForItemAt 的封装）
        items
            .bind(to: collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                              for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(row)：\(element)"
                return cell
        }
        .disposed(by: disposeBag)
        
        
        //获取选中项的索引
        collectionView.rx.itemSelected.subscribe(onNext: { indexPath in
            print("选中项的indexPath为：\(indexPath)")
            if indexPath.item == 0 {
                self.navigationController?.pushViewController(ViewController2(), animated: true)
            } else if indexPath.item == 1 {
                self.navigationController?.pushViewController(ViewController3(), animated: true)
            } else if indexPath.item == 2 {
                self.navigationController?.pushViewController(ViewController4(), animated: true)
            }
        }).disposed(by: disposeBag)
        
        
        //获取选中项的内容
        collectionView.rx.modelSelected(String.self).subscribe(onNext: { item in
            print("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        // 同时获取选中项的索引，以及内容
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
            .bind { [weak self] indexPath, item in
                self?.showMessage("选中项的indexPath为：\(indexPath)")
                self?.showMessage("选中项的标题为：\(item)")
        }
        .disposed(by: disposeBag)
        
        
        
        
        //获取被取消选中项的索引
        collectionView.rx.itemDeselected.subscribe(onNext: { [weak self] indexPath in
            self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取被取消选中项的内容
        collectionView.rx.modelDeselected(String.self).subscribe(onNext: {[weak self] item in
            self?.showMessage("被取消选中项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        Observable
            .zip(collectionView.rx.itemDeselected, collectionView.rx.modelDeselected(String.self))
            .bind { [weak self] indexPath, item in
                self?.showMessage("被取消选中项的indexPath为：\(indexPath)")
                self?.showMessage("被取消选中项的的标题为：\(item)")
        }
        .disposed(by: disposeBag)
        
        
        
        
        //获取选中并高亮完成后的索引
        collectionView.rx.itemHighlighted.subscribe(onNext: { indexPath in
            print("高亮单元格的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取高亮转成非高亮完成后的索引
        collectionView.rx.itemUnhighlighted.subscribe(onNext: { indexPath in
            print("失去高亮的单元格的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        
        
        //单元格将要显示出来的事件响应
        collectionView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            print("将要显示单元格indexPath为：\(indexPath)")
            print("将要显示单元格cell为：\(cell)\n")
        }).disposed(by: disposeBag)
        
        
        
        
        //分区头部、尾部将要显示出来的事件响应
        collectionView.rx.willDisplaySupplementaryView.subscribe(onNext: { view, kind, indexPath in
            print("将要显示分区indexPath为：\(indexPath)")
            print("将要显示的是头部还是尾部：\(kind)")
            print("将要显示头部或尾部视图：\(view)\n")
        }).disposed(by: disposeBag)
    }
    
    private func showMessage(_ message: String) {
        print(message)
    }
}

