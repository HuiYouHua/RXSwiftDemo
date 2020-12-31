//
//  ViewController4.swift
//  37UICollectionView1
//
//  Created by 华惠友 on 2020/12/28.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class ViewController4: UIViewController {
    //集合视图
    var collectionView:UICollectionView!
    
    let disposeBag = DisposeBag()
    public lazy var refreshBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("刷新", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "UICollectionView的使用4：样式修改"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: refreshBtn)]
        
        //定义布局方式以及单元格大小
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100, height: 70)
        
        //创建集合视图
        self.collectionView = UICollectionView(frame: self.view.frame,
                                               collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
        
        //创建一个重用的单元格
        self.collectionView.register(MyCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(self.collectionView!)
        
        //随机的表格数据
        let randomResult = refreshBtn.rx.tap.asObservable()
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest(getRandomResult)
            .share(replay: 1)
        
        //创建数据源
        let dataSource = RxCollectionViewSectionedReloadDataSource
        <SectionModel<String, Int>>(
            configureCell: { (dataSource, collectionView, indexPath, element) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                              for: indexPath) as! MyCollectionViewCell
                cell.label.text = "\(element)"
                return cell}
        )
        
        //绑定单元格数据
        randomResult
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //设置代理
                collectionView.rx.setDelegate(self)
                    .disposed(by: disposeBag)
    }
    
    //获取随机数据
    func getRandomResult() -> Observable<[SectionModel<String, Int>]> {
        print("正在请求数据......")
        let items = (0 ..< 5).map {_ in
            Int(arc4random_uniform(100000))
        }
        let observable = Observable.just([SectionModel(model: "S", items: items)])
        return observable.delay(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    }
    
    
}

//collectionView代理实现
extension ViewController4 : UICollectionViewDelegateFlowLayout {
    //设置单元格尺寸
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let cellWidth = (width - 30) / 4 //每行显示4个单元格
        return CGSize(width: cellWidth, height: cellWidth * 1.5) //单元格宽度为高度1.5倍
    }
}
