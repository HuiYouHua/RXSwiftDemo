//
//  ViewController.swift
//  28UIPickerView的使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    var pickerView:UIPickerView!
    
    //最简单的pickerView适配器（显示普通文本）
    private let stringPickerAdapter = RxPickerViewAttributedStringAdapter<[[String]]>(
        components: [],
        numberOfComponents: { dataSource,pickerView,components  in components.count },
        numberOfRowsInComponent: { (_, _, components, component) -> Int in
            return components[component].count},
        attributedTitleForRow: { (_, _, components, row, component) -> NSAttributedString? in
            return NSAttributedString(string: components[component][row],
                                      attributes: [
                                        NSAttributedString.Key.foregroundColor: UIColor.orange, //橙色文字
                                        NSAttributedString.Key.underlineStyle:
                                            NSUnderlineStyle.double.rawValue, //双下划线
                                        NSAttributedString.Key.textEffect:
                                            NSAttributedString.TextEffectStyle.letterpressStyle
                                      ])
        }
    )
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //创建pickerView
        pickerView = UIPickerView()
        self.view.addSubview(pickerView)
        
        //绑定pickerView数据
        Observable.just([["One", "Two", "Tree"],
                         ["A", "B", "C", "D"]])
            .bind(to: pickerView.rx.items(adapter: stringPickerAdapter))
            .disposed(by: disposeBag)
        
        //建立一个按钮，触摸按钮时获得选择框被选择的索引
        let button = UIButton(frame:CGRect(x:0, y:0, width:100, height:30))
        button.center = self.view.center
        button.backgroundColor = UIColor.blue
        button.setTitle("获取信息",for:.normal)
        //按钮点击响应
        button.rx.tap
            .bind { [weak self] in
                self?.getPickerViewValue()
            }
            .disposed(by: disposeBag)
        self.view.addSubview(button)
    }
    
    //触摸按钮时，获得被选中的索引
    @objc func getPickerViewValue(){
        let message = String(pickerView.selectedRow(inComponent: 0)) + "-"
            + String(pickerView!.selectedRow(inComponent: 1))
        let alertController = UIAlertController(title: "被选中的索引为",
                                                message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

