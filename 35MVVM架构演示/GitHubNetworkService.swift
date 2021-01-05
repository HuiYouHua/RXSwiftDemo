//
//  GitHubNetworkService.swift
//  35MVVM
//
//  Created by 华惠友 on 2021/1/5.
//  Copyright © 2021 com.development. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import ObjectMapper
 
class GitHubNetworkService {
     
    //搜索资源数据
//    func searchRepositories(query:String) -> Observable<GitHubRepositories> {
//        return GitHubProvider.rx.request(.repositories(query))
//            .filterSuccessfulStatusCodes()
//            .mapObject(GitHubRepositories.self)
//            .asObservable()
//            .catchError({ error in
//                print("发生错误：",error.localizedDescription)
//                return Observable<GitHubRepositories>.empty()
//            })
//    }
    
    //搜索资源数据
    func searchRepositories(query:String) -> Driver<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapObject(GitHubRepositories.self)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
}
