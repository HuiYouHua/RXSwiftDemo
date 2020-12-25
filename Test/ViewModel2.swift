//
//  ViewModel2.swift
//  Test
//
//  Created by 华惠友 on 2020/12/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewModel2 {
    //初始化数据
    func sectionableData() -> BehaviorRelay<[MySection]> {
        
        let section1 = MySection(header: "基本控件", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
            ])
        let section2 = MySection(header: "高级控件", items: [
                "UITableView的用法",
                "UICollectionViews的用法"
            ])
        return BehaviorRelay(value: [section1, section2])
    }
    
    //    func sectionableData() -> BehaviorRelay<[MySection<MGItem>]> {
    //        let item1 = MGItem(str: "1")
    //        let item2 = MGItem(str: "2")
    //        let item3 = MGItem(str: "4")
    //        let item4 = MGItem(str: "5")
    //
    //        let section1 = MGSection(header: "header1", items: [item1, item2])
    //        let section2 = MGSection(header: "header2", items: [item3, item4])
    //
    //        return BehaviorRelay(value: [section1, section2])
    //
    //    }
}
