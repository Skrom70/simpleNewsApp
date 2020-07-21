//
//  TopNews.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/23/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import UIKit

struct TopStories: Codable {
    let status: String?
    let section: String?
    let num_results: Int?
    let results: [TopArticle]?
}

struct TopArticle: Codable {
    let title: String
    let abstract: String
    let url: String
//    let byline: String
//    let created_date: String
//    let des_facet: [String]
    let org_facet: [String]
//    let geo_facet: [String]
//    let item_type: String
//    let kicker: String
//    let material_type_facet: String
    let multimedia: [Multimedia]?
//    let section: String
}

struct Multimedia: Codable {
    let format: String?
    let subType: String?
    let type: String?
    let url: String
}


extension TopArticle {
    var imageURL: URL? {
        if let stringURL = self.multimedia?.filter({$0.format == "superJumbo"}).first?.url,
            let url = URL(string: stringURL) {
            return url
        } else {
            return nil
        }
    }
}

extension TopArticle: RealmMappableProtocol {
    func mapToRealmObject(marker: String) -> RealmStory {
        let object = RealmStory()
        object.articleURL = self.url
        object.imageURL = self.multimedia?.filter({$0.format == "superJumbo"}).first?.url ?? ""
        object.title = self.title
        object.source = self.org_facet.first ?? ""
        object.desc = self.abstract
        object.marker = marker
        return object
    }
    
    static func mapFromRealmObject(_ object: RealmStory) -> TopArticle {
        let article = TopArticle(title: object.title, abstract: object.desc, url: object.articleURL, org_facet: [object.source], multimedia: [Multimedia(format: "superJumbo", subType: nil, type: nil, url: object.imageURL)])
        return article
    }
}
