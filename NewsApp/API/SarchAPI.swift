//
//  SarchAPI.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/26/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import Moya

enum SearchAPI {
    case search(q: String, page: Int)
    
    static let searchBasePath = "https://api.nytimes.com/svc/search/v2/"
}


extension SearchAPI: TargetType {
    var baseURL: URL {
        return URL(string: SearchAPI.searchBasePath)!
    }
    
    var path: String {
        return "articlesearch.json"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .search(let query, let page):
            return .requestParameters(parameters: ["q": query, "page": page, "api-key" : StoriesAPI.apiKey], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
