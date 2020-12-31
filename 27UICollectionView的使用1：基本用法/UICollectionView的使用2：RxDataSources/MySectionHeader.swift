//
//  MySectionHeader.swift
//  27UICollectionView1
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

class MySectionHeader: UICollectionReusableView {
    var label:UILabel!
     
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        //背景设为黑色
        self.backgroundColor = UIColor.black
         
        //创建文本标签
        label = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.textAlignment = .center
        self.addSubview(label)
    }
     
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
