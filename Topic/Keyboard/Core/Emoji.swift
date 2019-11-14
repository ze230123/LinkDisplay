//
//  Emoji.swift
//  Topic
//
//  Created by youzy01 on 2019/11/8.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

struct Emoji: Decodable {
    var name: String = ""
    var value: String = ""

    var image: UIImage? {
        let file = Bundle.main.path(forResource: "Sticker.bundle/\(value)", ofType: "png") ?? ""
        return UIImage(contentsOfFile: file)
    }
}
