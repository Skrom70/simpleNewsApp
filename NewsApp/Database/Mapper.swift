//
//  Mapper.swift
//  NewsApp
//
//  Created by Viacheslav Tolstopiatenko on 3/26/20.
//  Copyright © 2020 Vicheslav Tolstopiatnko. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmMappableProtocol {
    associatedtype RealmType: Object
    func mapToRealmObject(marker: String) -> RealmType
    static func mapFromRealmObject(_ object: RealmType) -> Self
}




