//
//  Display.swift
//  Topic
//
//  Created by youzy01 on 2019/11/11.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

class Display {
    var font: UIFont = UIFont.systemFont(ofSize: 15)

    var pattern = "\\{\"type\":\"(@|#)\",\"name\":\"([\u{4e00}-\u{9fa5}\\w])+\",\"id\":\"([\u{4e00}-\u{9fa5}\\w])+\"\\}"

    func urlRanges(text: String) -> [JsonRange]? {
        let pattern = "\\{\"\\w+\":\"(@|#)\",\"\\w+\":\"([\u{4e00}-\u{9fa5}\\w])+\",\"\\w+\":\"([\u{4e00}-\u{9fa5}\\w])+\"\\}"
        return findRanges(pattern: pattern, text: text)
    }

    func emojiRanges(text: String) -> [JsonRange]? {
        let pattern = "\\[([\\u4e00-\\u9fa5\\w])+\\]"
        return findRanges(pattern: pattern, text: text)
    }

    func findRanges(pattern: String, text: String) -> [JsonRange]? {
        do {
            let regx = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regx.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            let ranges = matches.map { JsonRange(json: NSString(string: text).substring(with: $0.range(at: 0)), range:  $0.range(at: 0)) }
            return ranges
        } catch let error {
            print(error)
            return nil
        }
    }

    func displayValue(_ value: String) -> (String, [String: TextLink]) {
        let ranges = urlRanges(text: value) ?? []
        var dict: [String: TextLink] = [:]

        ranges.forEach { (item) in
            if let item = TextLink(JSONString: item.json) {
                dict[item.key] = item
            }
        }

        var result: String = value

        dict.forEach { (key, value) in
            let json = value.json
            result = result.replacingOccurrences(of: json, with: key)
        }
        return (result, dict)
    }

    func replaceImage(_ value: String) -> NSMutableAttributedString {
        let attribut = NSMutableAttributedString(string: value)
        func replace(attributedString: NSMutableAttributedString) {
            let ranges = emojiRanges(text: attributedString.string) ?? []
            if let range = ranges.first {
                let str = attributedString.attributedSubstring(from: range.range).string
                let att = NSTextAttachment()
                let file = Bundle.main.path(forResource: "Sticker.bundle/\(EmojiManager.shared.imageNameForKey(str))", ofType: "png") ?? ""
                att.image = UIImage(contentsOfFile: file)
                att.bounds = CGRect(x: 0, y: font.descender - 2, width: font.lineHeight + 4, height: font.lineHeight + 4)
                let emojiAtt = NSAttributedString(attachment: att)
                attributedString.replaceCharacters(in: range.range, with: emojiAtt)
                replace(attributedString: attributedString)
            }
        }
        replace(attributedString: attribut)
        return attribut
    }
}

extension Display {
    struct JsonRange {
        var json: String = ""
        var range: NSRange
    }
}
