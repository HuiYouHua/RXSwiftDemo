//
//  ViewController.swift
//  32结合Moya使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import ObjectMapper
import Moya
import Result

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
        
        
    }
    
    
    // MARK: -  网络请求
    func test1() {
        //获取数据
        DouBanProvider.rx.request(.channels)
            .subscribe { event in
                switch event {
                case let .success(response):
                    //数据处理
                    let str = String(data: response.data, encoding: String.Encoding.utf8)
                    print("返回的数据是：", str ?? "")
                case let .error(error):
                    print("数据请求失败!错误原因：", error)
                }
            }.disposed(by: disposeBag)
        
        //获取数据
        DouBanProvider.rx.request(.channels)
            .subscribe(onSuccess: { response in
                //数据处理
                let str = String(data: response.data, encoding: String.Encoding.utf8)
                print("返回的数据是：", str ?? "")
            },onError: { error in
                print("数据请求失败!错误原因：", error)
            }).disposed(by: disposeBag)
    }
    
    // MARK: -  网络请求 JSON
    func test2() {
        //获取数据
        DouBanProvider.rx.request(.channels)
            .subscribe(onSuccess: { response in
                //数据处理
                let json = try? response.mapJSON() as? [String: Any]
                print("--- 请求成功！返回的如下数据 ---")
                print(json!)
            },onError: { error in
                print("数据请求失败!错误原因：", error)
                
            }).disposed(by: disposeBag)
        
        //获取数据
        DouBanProvider.rx.request(.channels)
            .mapJSON()
            .subscribe(onSuccess: { data in
                //数据处理
                let json = data as! [String: Any]
                print("--- 请求成功！返回的如下数据 ---")
                print(json)
            },onError: { error in
                print("数据请求失败!错误原因：", error)
                
            }).disposed(by: disposeBag)
        
        
        
        //获取列表数据
        let data = DouBanProvider.rx.request(.channels)
            .mapJSON()
            .map{ data -> [[String: Any]] in
                if let json = data as? [String: Any],
                   let channels = json["channels"] as? [[String: Any]] {
                    return channels
                }else{
                    return []
                }
            }.asObservable()
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element["name"]!)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }.disposed(by: disposeBag)
        
        //单元格点击
        tableView.rx.modelSelected([String: Any].self)
            .map{ $0["channel_id"] as! String }
            .flatMap{ DouBanProvider.rx.request(.playlist($0)) }
            .mapJSON()
            .subscribe(onNext: {[weak self] data in
                //解析数据，获取歌曲信息
                if let json = data as? [String: Any],
                   let musics = json["song"] as? [[String: Any]]{
                    let artist = musics[0]["artist"]!
                    let title = musics[0]["title"]!
                    let message = "歌手：\(artist)\n歌曲：\(title)"
                    //将歌曲信息弹出显示
                    self?.showAlert(title: "歌曲信息", message: message)
                }
            }).disposed(by: disposeBag)
    }
    
    
    
    // MARK: -  网络请求 模型转换
    func test3() {
        //获取数据
        DouBanProvider.rx.request(.channels)
            .mapObject(Douban.self)
            .subscribe(onSuccess: { douban in
                if let channels = douban.channels {
                    print("--- 共\(channels.count)个频道 ---")
                    for channel in channels {
                        if let name = channel.name, let channelId = channel.channelId {
                            print("\(name) （id:\(channelId)）")
                        }
                    }
                }
            }, onError: { error in
                print("数据请求失败!错误原因：", error)
            })
            .disposed(by: disposeBag)
        
        
        
        //获取列表数据
        let data = DouBanProvider.rx.request(.channels)
            .mapObject(Douban.self)
            .map{ $0.channels ?? [] }
            .asObservable()
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element.name!)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }.disposed(by: disposeBag)
        
        //单元格点击
        tableView.rx.modelSelected(Channel.self)
            .map{ $0.channelId! }
            .flatMap{ DouBanProvider.rx.request(.playlist($0)) }
            .mapObject(Playlist.self)
            .subscribe(onNext: {[weak self] playlist in
                //解析数据，获取歌曲信息
                if playlist.song.count > 0 {
                    let artist = playlist.song[0].artist!
                    let title = playlist.song[0].title!
                    let message = "歌手：\(artist)\n歌曲：\(title)"
                    //将歌曲信息弹出显示
                    self?.showAlert(title: "歌曲信息", message: message)
                }
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: -  网络请求 封装Service
    func test4() {
        //豆瓣网络请求服务
        let networkService = DouBanNetworkService()
        
        //获取列表数据
        let data = networkService.loadChannels()
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element.name!)"
            cell.accessoryType = .disclosureIndicator
            return cell
        }.disposed(by: disposeBag)
        
        //单元格点击
        tableView.rx.modelSelected(Channel.self)
            .map{ $0.channelId! }
            .flatMap(networkService.loadFirstSong)
            .subscribe(onNext: {[weak self] song in
                //将歌曲信息弹出显示
                let message = "歌手：\(song.artist!)\n歌曲：\(song.title!)"
                self?.showAlert(title: "歌曲信息", message: message)
            }).disposed(by: disposeBag)
    }
    
    //显示消息
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

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
struct Douban: Mappable {
    //频道列表
    var channels: [Channel]?
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        channels <- map["channels"]
    }
}

//频道模型
struct Channel: Mappable {
    var name: String?
    var nameEn:String?
    var channelId: String?
    var seqId: Int?
    var abbrEn: String?
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        name <- map["name"]
        nameEn <- map["name_en"]
        channelId <- map["channel_id"]
        seqId <- map["seq_id"]
        abbrEn <- map["abbr_en"]
    }
}

//歌曲列表模型
struct Playlist: Mappable {
    var r: Int!
    var isShowQuickStart: Int!
    var song:[Song]!
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        r <- map["r"]
        isShowQuickStart <- map["is_show_quick_start"]
        song <- map["song"]
    }
}

//歌曲模型
struct Song: Mappable {
    var title: String!
    var artist: String!
    
    init?(map: Map) { }
    
    // Mappable
    mutating func mapping(map: Map) {
        title <- map["title"]
        artist <- map["artist"]
    }
}
