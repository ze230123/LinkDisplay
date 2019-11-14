//
//  ZYInputView.swift
//  Topic
//
//  Created by youzy01 on 2019/11/12.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

extension NSAttributedString.Key {
    static let emoji = NSAttributedString.Key("emoji")
}

protocol ZYInputViewDelegate: class {
    func inputView(_ inputView: ZYInputView, didSelectSendOf text: String)
}

@IBDesignable
class ZYInputView: UIView, NibLoadable {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!

    weak var delegate: ZYInputViewDelegate?

    var items: [Item] = []

    var linkAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.foregroundColor: UIColor.blue,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)
    ]

    lazy var keyboard: EmojiKeyboard = {
        let view = EmojiKeyboard()
        view.delegate = self
        return view
    }()

    var type: KeyboardType = .system {
        didSet {
            changeKeyboardType()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromNib()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    @IBAction func sendAction() {
        resignFirstResponder()
        willSendText()
    }

    @IBAction func emojiAction(_ sender: UIButton) {
        type = type.toggle
    }

    @IBAction func topicAction(_ sender: UIButton) {
    }

    @IBAction func userAction(_ sender: UIButton) {
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 89)
    }
}

extension ZYInputView {
    func addUser(_ item: Item) {
        let selectedRange = textView.selectedRange
        let att = NSMutableAttributedString(string: item.key)
        // 将这段文字打上标记,方便遍历
        att.addAttributes(linkAttributes, range: NSRange(location: 0, length: att.length))
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.replaceCharacters(in: selectedRange, with: att)
        textView.attributedText = attributedText
        textView.selectedRange = NSRange(location: selectedRange.location + att.length, length: 0)
        items.append(item)
    }

    func changeKeyboardType() {
        switch type {
        case .system:
            textView.inputView = nil
        case .emoji:
            textView.inputView = keyboard
        }
        textView.reloadInputViews()
    }

    func willSendText() {
        guard let attribute = textView.attributedText else { return }
        let range = NSRange(location: 0, length: attribute.length)
        var result = ""
        let string = attribute.string as NSString
        attribute.enumerateAttribute(.emoji, in: range, options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            if let value = value as? String {
                result += value
            } else {
                let rangString = string.substring(with: range)
                result += rangString
            }
        }
        items.forEach { (item) in
            result = result.replacingOccurrences(of: item.key, with: item.json)
        }
        delegate?.inputView(self, didSelectSendOf: result)
    }
}

extension ZYInputView: EmojiKeyboardDelegate {
    func emojikeyboard(_ emojikeyboard: EmojiKeyboard, didCheckItem emoji: Emoji) {
        let selectedRange = textView.selectedRange
        let font = UIFont.systemFont(ofSize: 16)
        let emojiHeight = font.lineHeight

        let attachment = NSTextAttachment()
        attachment.image = emoji.image
        attachment.bounds = CGRect(x: 0, y: font.descender, width: emojiHeight, height: emojiHeight)
        let att = NSMutableAttributedString(attachment: attachment)
        // 将这段文字打上标记,方便遍历
        att.addAttribute(.emoji, value: emoji.name, range: NSRange(location: 0, length: att.length))
        let attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        attributedText.replaceCharacters(in: selectedRange, with: att)
        textView.attributedText = attributedText
        textView.selectedRange = NSRange(location: selectedRange.location + att.length, length: 0)
    }

    func emojikeyboardDidSelectDelete(_ emojikeyboard: EmojiKeyboard) {
        print("删除")
        let selectedRange = self.textView.selectedRange
        if selectedRange.location == 0 && selectedRange.length == 0 {
            return
        }
        let attributedText = NSMutableAttributedString(attributedString: self.textView.attributedText)
        if selectedRange.length > 0 {
            //删除字符
            attributedText.deleteCharacters(in: selectedRange)
            self.textView.attributedText = attributedText
            self.textView.selectedRange = .init(location: selectedRange.location, length: 0)
        } else {
            //删除表情
            attributedText.deleteCharacters(in: .init(location: selectedRange.location - 1, length:  1))
            self.textView.attributedText = attributedText
            self.textView.selectedRange = .init(location: selectedRange.location - 1, length: 0)
        }
    }

    func emojikeyboardDidSelectSend(_ emojikeyboard: EmojiKeyboard) {
        resignFirstResponder()
        type = .system
        willSendText()
    }
}

extension ZYInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            willSendText()
            return false
        }
        return true
    }
}

enum KeyboardType {
    case system
    case emoji

    var toggle: KeyboardType {
        switch self {
        case .system:
            return .emoji
        case .emoji:
            return .system
        }
    }
}
