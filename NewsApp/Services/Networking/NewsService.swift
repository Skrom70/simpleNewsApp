//
//  NewsService.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

final class NewsService {
    
    var storiesProvider = MoyaProvider<StoriesAPI>()
    var searchProvider = MoyaProvider<SearchAPI>()

    func fetchStories(section: StoriesAPI) -> Observable<TopStories> {
        return storiesProvider.rx.request(section).map(TopStories.self).asObservable()
    }
    
    func searchArticles(q: String, page: Int = 0) -> Observable<Articles> {
        return searchProvider.rx.request(.search(q: q, page: page)).map(Articles.self).asObservable()
    }
}
