//
//  MGSection.swift
//  Test
//
//  Created by 华惠友 on 2020/12/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct MyItem {
    var str: Sting
}

struct MySection: AnimatableSectionModelType {
    typealias Item = String
    
    var header: String
    var items: [Item]
     
    var identity: String {
        return header
    }
     
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}
