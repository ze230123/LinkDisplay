//
//  ZYTextView.swift
//  Topic
//
//  Created by youzy01 on 2019/11/15.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func stringForRange(_ range: NSRange, links: [TextLink]) -> String {
        var result = ""
        enumerateAttribute(.emoji, in: range, options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if let value = value as? String {
                result += value
            } else {
                let rangString = string.substring(range: range)
                result += rangString
            }
        }
        links.forEach { (item) in
            result = result.replacingOccurrences(of: item.key, with: item.json)
        }
        return result
    }
}

class ZYTextView: UITextView {
    var linkColor: UIColor = #colorLiteral(red: 0.3137254902, green: 0.4901960784, blue: 0.6862745098, alpha: 1)

    var links: [TextLink] = []

    var zy_text: String {
        let range = NSRange(location: 0, length: attributedText.length)
        return attributedText.stringForRange(range, links: links)
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        if #available(iOS 11.0, *) {
            textDragInteraction?.isEnabled = false
        }
    }

    override func becomeFirstResponder() -> Bool {
        inputView = nil
        return super.becomeFirstResponder()
    }
}

extension ZYTextView {
    func addLink(_ item: TextLink) {
        guard let font = font else { return }
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: linkColor
        ]

        let imageAtt = NSAttributedString(string: item.key, attributes: linkAttributes)
        let attachment = NSTextAttachment()
        let image = imageAtt.asImage(height: font.lineHeight)
        attachment.image = image

        attachment.bounds = CGRect(x: 0, y: font.descender, width: image?.size.width ?? 0, height: image?.size.height ?? 0)
        let att = NSMutableAttributedString(attachment: attachment)
        // 将这段文字打上标记,方便遍历
        att.addAttribute(.emoji, value: item.json, range: NSRange(location: 0, length: att.length))
        att.addAttribute(.font, value: font, range: NSRange(location: 0, length: att.length))

        let attributed = NSMutableAttributedString(attributedString: attributedText)
        attributed.replaceCharacters(in: selectedRange, with: att)
        attributedText = attributed
        selectedRange = NSRange(location: selectedRange.location + att.length, length: 0)
        links.append(item)
    }

    func addEmoji(_ emoji: Emoji) {
        guard let font = font else { return }
        let emojiHeight = font.lineHeight

        let attachment = NSTextAttachment()
        attachment.image = emoji.image
        attachment.bounds = CGRect(x: 0, y: font.descender, width: emojiHeight, height: emojiHeight)
        let att = NSMutableAttributedString(attachment: attachment)
        // 将这段文字打上标记,方便遍历
        att.addAttribute(.emoji, value: emoji.name, range: NSRange(location: 0, length: att.length))
        att.addAttribute(.font, value: font, range: NSRange(location: 0, length: att.length))
        let attributed = NSMutableAttributedString(attributedString: attributedText)
        attributed.replaceCharacters(in: selectedRange, with: att)
        attributedText = attributed
        selectedRange = NSRange(location: selectedRange.location + att.length, length: 0)
    }
}
