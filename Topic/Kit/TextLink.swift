//
//  Item.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit
import ObjectMapper

struct LinkType: Hashable, Equatable, RawRepresentable {
    var rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension LinkType {
    static let atUser = LinkType("@")
    static let topic = LinkType("#")
}

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

    var linkType: LinkType {
        return LinkType(type)
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
