//
//  MusicViewModel.swift
//  01响应式编程
//
//  Created by 华惠友 on 2020/4/25.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift

class MusicViewModel: NSObject {

    let data = Observable.just([
        Music(name: "无条件", singer: "陈奕迅"),
        Music(name: "你曾是少年", singer: "S.H.E"),
        Music(name: "从前的我", singer: "陈洁仪"),
        Music(name: "在木星", singer: "朴树"),
    ])
}
