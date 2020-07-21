//
//  NewsAPI.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import Moya

enum StoriesAPI: String {
    case homeStories = "homeStories"
    case artsStories = "artsStories"
    case sportsStories = "sportsStories"
    case scienceStories = "scienceStories"
    
    static let storiesBasePath = "https://api.nytimes.com/svc/topstories/v2/"
    static let apiKey = "CjoZTYEVPxctEkNk9k1XJ8r7G0L63SqA"
}

extension StoriesAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .homeStories, .artsStories, .sportsStories, .scienceStories:
            return URL(string: StoriesAPI.storiesBasePath)!
        }
    }
    
    var path: String {
        switch self {
        case .homeStories:
            return "home.json"
        case .artsStories:
            return "arts.json"
        case .sportsStories:
            return "sports.json"
        case .scienceStories:
            return "science.json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .homeStories, .artsStories, .sportsStories, .scienceStories:
            return .requestParameters(parameters: ["api-key" : StoriesAPI.apiKey], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
