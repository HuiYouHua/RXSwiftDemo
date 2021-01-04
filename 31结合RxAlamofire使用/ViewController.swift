//
//  ViewController.swift
//  31结合RxAlamofire使用
//
//  Created by 华惠友 on 2020/12/31.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import RxAlamofire
import Alamofire

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
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        
        //创建并发起请求
        request(.get, url)
            .data()
            .subscribe(onNext: {
                data in
                //数据处理
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("返回的数据是：", str ?? "")
            }, onError: { error in
                print("请求失败！错误原因：", error)
            }).disposed(by: disposeBag)
        
        //创建并发起请求
        requestData(.get, url).subscribe(onNext: {
            response, data in
            //判断响应结果状态码
            if 200 ..< 300 ~= response.statusCode {
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("请求成功！返回的数据是：", str ?? "")
            }else{
                print("请求失败！")
            }
        }).disposed(by: disposeBag)
        
        ///直接获取String类型数据
        //创建并发起请求
        request(.get, url)
            .responseString()
            .subscribe(onNext: {
                response, data in
                //数据处理
                print("返回的数据是：", data)
            }).disposed(by: disposeBag)
        
        //创建并发起请求
        ///也可直接requestString
        requestString(.get, url)
            .subscribe(onNext: {
                response, data in
                //数据处理
                print("返回的数据是：", data)
            }).disposed(by: disposeBag)
        
        
        //发起请求按钮点击
        startBtn.rx.tap.asObservable()
            .flatMap {
                request(.get, url).responseString()
                    .takeUntil(self.cancelBtn.rx.tap) //如果“取消按钮”点击则停止请求
            }
            .subscribe(onNext: {
                response, data in
                print("请求成功！返回的数据是：", data)
            }, onError: { error in
                print("请求失败！错误原因：", error)
            }).disposed(by: disposeBag)
    }
    
    // MARK: -  网络请求数据转JSON
    func test2() {
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        
        //创建并发起请求
        request(.get, url)
            .data()
            .subscribe(onNext: {
                data in
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    as? [String: Any]
                print("--- 请求成功！返回的如下数据 ---")
                print(json!)
            }).disposed(by: disposeBag)
        
        //创建并发起请求
        request(.get, url)
            .responseJSON()
            .subscribe(onNext: {
                dataResponse in
                let json = dataResponse.value as! [String: Any]
                print("--- 请求成功！返回的如下数据 ---")
                print(json)
            }).disposed(by: disposeBag)
        
        //创建并发起请求
        requestJSON(.get, url)
            .subscribe(onNext: {
                response, data in
                let json = data as! [String: Any]
                print("--- 请求成功！返回的如下数据 ---")
                print(json)
            }).disposed(by: disposeBag)
        
        
        //获取列表数据
        let data = requestJSON(.get, url)
            .map{ response, data -> [[String: Any]] in
                if let json = data as? [String: Any],
                   let channels = json["channels"] as? [[String: Any]] {
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
    
    // MARK: -  网络请求数据转模型
    func test3() {
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        
        
        //获取列表数据
        let data = requestJSON(.get, url)
            .map{$1}
            .mapObject(type: Douban.self)
            .map{ $0.channels ?? []}
        
        //将数据绑定到表格
        data.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row)：\(element.name!)"
            return cell
        }.disposed(by: disposeBag)
    }
    
    // MARK: -  文件上传
    func test4() {
        /**
         文件类型
         File
         Data
         Stream
         MultipartFormData
         */
        
        //需要上传的文件路径
        let fileURL = Bundle.main.url(forResource: "hangge", withExtension: "zip")
        //服务器路径
        let uploadURL = URL(string: "http://www.hangge.com/upload.php")!
        
        //将文件上传到服务器
        //将文件上传到服务器
        upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL))
            .subscribe(onNext: { element in
                print("--- 开始上传 ---")
                element.uploadProgress(closure: { (progress) in
                    print("当前进度：\(progress.fractionCompleted)")
                    print("  已上传载：\(progress.completedUnitCount/1024)KB")
                    print("  总大小：\(progress.totalUnitCount/1024)KB")
                })
            }, onError: { error in
                print("上传失败! 失败原因：\(error)")
            }, onCompleted: {
                print("上传完毕!")
            })
            .disposed(by: disposeBag)
        
        
        ///进度的另一种写法
        let progressView = UIProgressView()
        //将文件上传到服务器
        upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL))
            .map{request in
                //返回一个关于进度的可观察序列
                Observable<Float>.create{observer in
                    request.uploadProgress(closure: { (progress) in
                        observer.onNext(Float(progress.fractionCompleted))
                        if progress.isFinished{
                            observer.onCompleted()
                        }
                    })
                    return Disposables.create()
                }
            }
            .flatMap{$0}
            .bind(to: progressView.rx.progress) //将进度绑定UIProgressView上
            .disposed(by: disposeBag)
    }
    
    // MARK: -  文件上传MultipartFormData格式
    func test5() {
        let fileURL1 = Bundle.main.url(forResource: "0", withExtension: "png")
        let fileURL2 = Bundle.main.url(forResource: "1", withExtension: "png")
        
        //字符串
        let strData = "hangge.com".data(using: String.Encoding.utf8)
        //数字
        let intData = String(10).data(using: String.Encoding.utf8)
        //文件1
        let path = Bundle.main.url(forResource: "0", withExtension: "png")!
        let file1Data = try! Data(contentsOf: path)
        //文件2
        let file2URL = Bundle.main.url(forResource: "1", withExtension: "png")
        
        //服务器路径
        let uploadURL = URL(string: "http://www.hangge.com/upload2.php")!
        
        //将文件上传到服务器
        upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileURL1!, withName: "file1")
                multipartFormData.append(fileURL2!, withName: "file2")
            },
            to: uploadURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        
        //将文件上传到服务器
        ///文本参数与文件一起提交（文件除了可以使用 fileURL，还可以上传 Data 类型的文件数据）
        upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(strData!, withName: "value1")
                multipartFormData.append(intData!, withName: "value2")
                multipartFormData.append(file1Data, withName: "file1",
                                         fileName: "php.png", mimeType: "image/png")
                multipartFormData.append(file2URL!, withName: "file2")
            },
            to: uploadURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
    }
    
    // MARK: -  文件下载
    func test6() {
        //指定下载路径（文件名不变）
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(response.suggestedFilename!)
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        //指定下载路径和保存文件名
        //        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        //            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //            let fileURL = documentsURL.appendingPathComponent("file1/myLogo.png")
        //            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
        //            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        //        }
        
        //需要下载的文件
        let fileURL = URL(string: "http://www.hangge.com/blog/images/logo.png")!
        
        //开始下载
        download(URLRequest(url: fileURL), to: destination)
            .subscribe(onNext: { element in
                print("开始下载。")
                element.downloadProgress(closure: { progress in
                    print("当前进度: \(progress.fractionCompleted)")
                    print("  已下载：\(progress.completedUnitCount/1024)KB")
                    print("  总大小：\(progress.totalUnitCount/1024)KB")
                })
            }, onError: { error in
                print("下载失败! 失败原因：\(error)")
            }, onCompleted: {
                print("下载完毕!")
            }).disposed(by: disposeBag)
        
        
        
        //开始下载
        let progressView = UIProgressView()
        
        download(URLRequest(url: fileURL), to: destination)
            .map{request in
                //返回一个关于进度的可观察序列
                Observable<Float>.create{observer in
                    request.downloadProgress(closure: { (progress) in
                        observer.onNext(Float(progress.fractionCompleted))
                        if progress.isFinished{
                            observer.onCompleted()
                        }
                    })
                    return Disposables.create()
                }
            }
            .flatMap{$0}
            .bind(to: progressView.rx.progress) //将进度绑定UIProgressView上
            .disposed(by: disposeBag)
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
