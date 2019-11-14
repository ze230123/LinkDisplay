//
//  EmojiManager.swift
//  Topic
//
//  Created by youzy01 on 2019/11/8.
//  Copyright © 2019 youzy. All rights reserved.
//

import Foundation

class EmojiManager {
    static let shared = EmojiManager()

    private(set) var items: [String: String] = [:]

    init() {
        if let path = Bundle.main.url(forResource: "InnerStickersInfo.plist", withExtension: nil) {
            let dict = NSDictionary(contentsOf: path) as? [String: String] ?? [:]
            items = dict
        }
    }

    func imageNameForKey(_ key: String) -> String {
        return items[key] ?? ""
    }
}
