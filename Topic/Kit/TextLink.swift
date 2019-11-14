//
//  Item.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit
import ObjectMapper

struct TextLink: Mappable {
    var type: String = ""
    var name: String = ""
    var id: String = ""

    var key: String {
        switch type {
        case "@":
            return type + name
        case "#":
            return type + name + type
        default:
            return ""
        }
    }

    init() {}

    init(type: String, name: String, id: String) {
        self.type = type
        self.name = name
        self.id = id
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        type    <- map["type"]
        name    <- map["name"]
        id      <- map["id"]
    }

    var json: String {
        return "{\"type\":\"\(type)\",\"name\":\"\(name)\",\"id\":\"\(id)\"}"
    }
}
