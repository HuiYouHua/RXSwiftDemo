//
//  ViewController.swift
//  30URLSession的使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    public lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("发起请求", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 84, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    public lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消请求", for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 84, height: 44)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: startBtn), UIBarButtonItem(customView: cancelBtn)]
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
        test4()
    }
    
    //MARK: - 网络请求
    func test1() {
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)
        //创建请求对象
        let request = URLRequest(url: url!)
        
        //创建并发起请求
        /**
         rx.data 与 rx.response 的区别：
         如果不需要获取底层的 response，只需知道请求是否成功，以及成功时返回的结果，那么建议使用 rx.data。
         因为 rx.data 会自动对响应状态码进行判断，只有成功的响应（状态码为 200~300）才会进入到 onNext 这个回调，否则进入 onError 这个回调。
         */
        URLSession.shared.rx.response(request: request).subscribe(onNext: {
            (response, data) in
            //判断响应结果状态码
            if 200 ..< 300 ~= response.statusCode {
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("请求成功！返回的数据是：", str ?? "")
            }else{
                print("请求失败！")
            }
        }).disposed(by: disposeBag)
        
        URLSession.shared.rx.data(request: request).subscribe(onNext: {
            data in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("请求成功！返回的数据是：", str ?? "")
        }, onError: { error in
            print("请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        //发起请求按钮点击
        startBtn.rx.tap.asObservable()
            .flatMap {
                URLSession.shared.rx.data(request: request)
                    .takeUntil(self.cancelBtn.rx.tap) //如果“取消按钮”点击则停止请求
            }
            .subscribe(onNext: {
                data in
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("请求成功！返回的数据是：", str ?? "")
            }, onError: { error in
                print("请求失败！错误原因：", error)
            }).disposed(by: disposeBag)
    }
    
    
    //MARK: - 结果处理、模型转换
    func test2() {
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)
        //创建请求对象
        let request = URLRequest(url: url!)
        
        //创建并发起请求
        URLSession.shared.rx.data(request: request).subscribe(onNext: {
            data in
            ///请求后进行转换
            let json = try? (JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                as? [String: Any])
            print("--- 请求成功！返回的如下数据 ---")
            print(json!)
        }).disposed(by: disposeBag)
        
        ///订阅时转换
        URLSession.shared.rx.data(request: request)
            .map {
                try JSONSerialization.jsonObject(with: $0, options: .allowFragments)
                    as! [String: Any]
            }
            .subscribe(onNext: {
                data in
                print("--- 请求成功！返回的如下数据 ---")
                print(data)
            }).disposed(by: disposeBag)
        
        //使用Rxswift提供的转换方式
        URLSession.shared.rx.json(request: request).subscribe(onNext: {
            data in
            let json = data as! [String: Any]
            print("--- 请求成功！返回的如下数据 ---")
            print(json )
        }).disposed(by: disposeBag)
    }
    
    //MARK: - 解析展示数据
    func test3() {
        //获取列表数据
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)
        //创建请求对象
        let request = URLRequest(url: url!)
        let data = URLSession.shared.rx.json(request: request)
            .map{ result -> [[String: Any]] in
                if let data = result as? [String: Any],
                   let channels = data["channels"] as? [[String: Any]] {
                    return channels
                }else{
                    return []
                }
            }
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row)：\(element["name"]!)"
            return cell
        }.disposed(by: disposeBag)
    }
    
    //MARK: - ObjectMapper解析展示数据
    func test4() {
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)
        //创建请求对象
        let request = URLRequest(url: url!)
        
        //获取列表数据
        let data = URLSession.shared.rx.json(request: request)
            .mapObject(type: Douban.self)
            .map{ $0.channels ?? []}
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row)：\(element.name!)"
            return cell
        }.disposed(by: disposeBag)
    }
}


///为了让 ObjectMapper 能够更好地与 RxSwift 配合使用，我们对 Observable 进行扩展（RxObjectMapper.swift），增加数据转模型对象、以及数据转模型对象数组这两个方法
//数据映射错误
public enum RxObjectMapperError: Error {
    case parsingError
}

//扩展Observable：增加模型映射方法
public extension Observable where Element:Any {
    
    //将JSON数据转成对象
    func mapObject< T>(type:T.Type) -> Observable<T> where T:Mappable {
        let mapper = Mapper<T>()
        
        return self.map { (element) -> T in
            guard let parsedElement = mapper.map(JSONObject: element) else {
                throw RxObjectMapperError.parsingError
            }
            return parsedElement
        }
    }
    
    //将JSON数据转成数组
    func mapArray< T>(type:T.Type) -> Observable<[T]> where T:Mappable {
        let mapper = Mapper<T>()
        
        return self.map { (element) -> [T] in
            guard let parsedArray = mapper.mapArray(JSONObject: element) else {
                throw RxObjectMapperError.parsingError
            }
            return parsedArray
        }
    }
}

//豆瓣接口模型
class Douban: Mappable {
    //频道列表
    var channels: [Channel]?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        channels <- map["channels"]
    }
}

//频道模型
class Channel: Mappable {
    var name: String?
    var nameEn:String?
    var channelId: String?
    var seqId: Int?
    var abbrEn: String?
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        name <- map["name"]
        nameEn <- map["name_en"]
        channelId <- map["channel_id"]
        seqId <- map["seq_id"]
        abbrEn <- map["abbr_en"]
    }
}
