//
//  Article.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/25/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation


struct Articles: Codable {
    let status: String?
    let response: ArticlesRescponse?
    
}


struct ArticlesRescponse: Codable {
    let docs: [Article]?
    let meta: Meta?
}

struct Article: Codable {
    let abstract: String?
    let web_url: String?
    let source: String?
    let lead_paragraph: String?
    let print_section: String?
    let print_page: String?
    let multimedia: [ArticaleMultimedia]?
    let headline: Headline?
}


struct Headline: Codable {
    let main: String?
}
struct ArticaleMultimedia: Codable {
    let subType: String?
    let type: String?
    let url: String?
    var fullURL: String? {
        if let url = self.url {
            return "https://static01.nyt.com/" + url
        } else {
            return nil
        }
    }
}

struct Meta: Codable {
    let hits: Int?
    let offset: Int?
}


extension Article {
    var imageURL: URL? {
        if let stringURL = (self.multimedia?.filter({$0.subType == "superJumbo"}).first?.fullURL), let url = URL(string: stringURL) {
            return url
        }
        else if let stringURL = self.multimedia?.filter({$0.subType == "xlarge"}).first?.fullURL, let url = URL(string: stringURL) {
            return url
        } else {
            return nil
        }
    }
}


extension Article: RealmMappableProtocol {
    
    func mapToRealmObject(marker: String) -> RealmStory {
        let object = RealmStory()
        object.articleURL = self.web_url ?? ""
        object.imageURL = imageURL?.absoluteString ?? ""
        object.title = self.headline?.main ?? ""
        object.source = self.source ?? ""
        object.desc = self.abstract ?? ""
        object.marker = marker
        return object
    }
    
    static func mapFromRealmObject(_ object: RealmStory) -> Article {
        let act = Article(abstract: object.desc, web_url: object.articleURL, source: object.source, lead_paragraph: nil, print_section: nil, print_page: nil, multimedia: [ArticaleMultimedia(subType: "superJumbo", type: nil, url: object.imageURL)], headline: nil)
        return act
    }
}
