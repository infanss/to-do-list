//
//  Category.swift
//  Todoey
//
//  Created by Яна Колобовникова   on 17.09.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
   @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    
    var items = List<Item>()
}
