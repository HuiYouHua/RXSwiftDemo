//
//  GitHubRepositories.swift
//  35MVVM
//
//  Created by 华惠友 on 2021/1/5.
//  Copyright © 2021 com.development. All rights reserved.
//

import Foundation
import ObjectMapper
 
//包含查询返回的所有库模型
struct GitHubRepositories: Mappable {
    var totalCount: Int!
    var incompleteResults: Bool!
    var items: [GitHubRepository]! //本次查询返回的所有仓库集合
     
    init() {
        print("init()")
        totalCount = 0
        incompleteResults = false
        items = []
    }
     
    init?(map: Map) { }
     
    // Mappable
    mutating func mapping(map: Map) {
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        items <- map["items"]
    }
}
 
//单个仓库模型
struct GitHubRepository: Mappable {
    var id: Int!
    var name: String!
    var fullName:String!
    var htmlUrl:String!
    var description:String!
     
    init?(map: Map) { }
     
    // Mappable
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        fullName <- map["full_name"]
        htmlUrl <- map["html_url"]
        description <- map["description"]
    }
}
