//
//  RealmDataManager.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 7/4/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import RealmSwift



class RealmStoryDataManager<PlainType: RealmMappableProtocol> {
    
    func find(marker: String) -> [PlainType] {
        let realm = try! Realm()
        let objects: [PlainType] = realm.objects(PlainType.RealmType.self).filter("marker == %@", marker).map({PlainType.mapFromRealmObject($0)})
        return objects
    }
    
    func save(marker: String, _ models: [PlainType]) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(models.map({ $0.mapToRealmObject(marker: marker) }), update: .all)
        }
    }
    
    func resave(marker: String, _ models: [PlainType]) {
        let realm = try! Realm()
        let objects = realm.objects(PlainType.RealmType.self).filter("marker == %@", marker)
        try! realm.write {
            realm.delete(objects)
            realm.add(models.map({ $0.mapToRealmObject(marker: marker) }), update: .all)
        }
    }
    
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
}
