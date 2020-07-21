//
//  RealmStory.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/26/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import RealmSwift


class RealmStory: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var articleURL: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var source: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var marker: String = ""
    @objc dynamic var desc: String = ""
}


