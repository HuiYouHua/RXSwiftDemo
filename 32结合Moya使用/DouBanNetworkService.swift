//
//  DouBanNetworkService.swift
//  32Moya
//
//  Created by 华惠友 on 2021/1/4.
//  Copyright © 2021 com.development. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper
 
class DouBanNetworkService {
     
    //获取频道数据
    func loadChannels() -> Observable<[Channel]> {
        return DouBanProvider.rx.request(.channels)
            .mapObject(Douban.self)
            .map{ $0.channels ?? [] }
            .asObservable()
    }
     
    //获取歌曲列表数据
    func loadPlaylist(channelId:String) -> Observable<Playlist> {
        return DouBanProvider.rx.request(.playlist(channelId))
            .mapObject(Playlist.self)
            .asObservable()
    }
     
    //获取频道下第一首歌曲
    func loadFirstSong(channelId:String) -> Observable<Song> {
        return loadPlaylist(channelId: channelId)
            .filter{ $0.song.count > 0}
            .map{ $0.song[0] }
    }
}
