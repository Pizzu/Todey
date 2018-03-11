//
//  Category.swift
//  Todey
//
//  Created by Luca Lo Forte on 04/03/18.
//  Copyright © 2018 Luca Lo Forte. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var name : String = ""
    @objc dynamic var colorCategory : String = ""
    let items = List<Item>()
}


