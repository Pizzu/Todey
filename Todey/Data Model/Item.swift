//
//  Item.swift
//  Todey
//
//  Created by Luca Lo Forte on 04/03/18.
//  Copyright © 2018 Luca Lo Forte. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
