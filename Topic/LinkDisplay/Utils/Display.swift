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

//    var pattern = "\\{\"type\":\"(@|#)\",\"name\":\"([\u{4e00}-\u{9fa5}\\w])+\",\"id\":\"([\u{4e00}-\u{9fa5}\\w])+\"\\}"

    private func jsonRanges(text: String) -> [JsonRange]? {
        let pattern = "\\{\"\\w+\":\"(@|#)\",\"\\w+\":\"([\u{4e00}-\u{9fa5}\\w])+\",\"\\w+\":\"([\u{4e00}-\u{9fa5}\\w])+\"\\}"
        return findRanges(pattern: pattern, text: text)
    }

    private func emojiRanges(text: String) -> [JsonRange]? {
        let pattern = "\\[([\\u4e00-\\u9fa5\\w])+\\]"
        return findRanges(pattern: pattern, text: text)
    }

    private func findRanges(pattern: String, text: String) -> [JsonRange]? {
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

    func displayValue(_ value: String) -> (String, [String: TextLink], Set<NSRange>) {
        // 查找json Range
        let ranges = jsonRanges(text: value) ?? []
        var dict: [String: TextLink] = [:]
        // 将json转为模型、并存储
        ranges.forEach { (item) in
            if let item = TextLink(JSONString: item.json) {
                dict[item.key] = item
            }
        }

        var result: String = value
        // 替换json
        dict.forEach { (key, value) in
            let json = value.json
            result = result.replacingOccurrences(of: json, with: key)
        }

        // 查找替换json的字符串range
        var set = Set<NSRange>()
        dict.forEach { (key, value) in
            let ranges = self.findRanges(pattern: key, text: result)
            ranges?.forEach { (item) in
                set.insert(item.range)
            }
        }
        return (result, dict, set)
    }

    /// 替换表情
    func replaceImage(_ value: String) -> NSMutableAttributedString {
        let attribut = NSMutableAttributedString(string: value)
        /// 递归替换、一次替换一个、防止替换的位置不对
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
