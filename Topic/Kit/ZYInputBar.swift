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

protocol ZYInputBarDelegate: class {
    func inputBar(_ inputBar: ZYInputBar, didSelectSendOf text: String)
    func inputBarDidSelectAtUser(_ inputBar: ZYInputBar)
    func inputBarDidSelectTopic(_ inputBar: ZYInputBar)
}

/// 评论输入框
@IBDesignable
class ZYInputBar: UIView, NibLoadable {
    @IBOutlet weak var textView: ZYTextView!
    @IBOutlet weak var sendBtn: UIButton!

    weak var delegate: ZYInputBarDelegate?
    /// textView的delegate
    let textDelegate = TextDelegate()
    /// 表情键盘
    lazy var keyboard: EmojiKeyboard = {
        let view = EmojiKeyboard()
        view.delegate = self
        return view
    }()
    /// 当前键盘类型
    var type: KeyboardType = .system {
        didSet {
            changeKeyboardType()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromNib()
        setup()
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
    // 切换表情键盘
    @IBAction func emojiAction(_ sender: UIButton) {
        type = type.toggle
    }

    @IBAction func topicAction(_ sender: UIButton) {
        delegate?.inputBarDidSelectTopic(self)
    }

    @IBAction func userAction(_ sender: UIButton) {
        delegate?.inputBarDidSelectAtUser(self)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 89)
    }
}
// MARK: - public func
extension ZYInputBar {
    func addLink(_ item: TextLink) {
        textView.addLink(item)
    }
}
// MARK: - private func
private extension ZYInputBar {
    func setup() {
        textDelegate.delegate = self
        textView.delegate = textDelegate
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
        delegate?.inputBar(self, didSelectSendOf: textView.zy_text)
    }
}
// MARK: - ZYTextViewDelegate
extension ZYInputBar: ZYTextViewDelegate {
    func textViewDidSelectSendItem(_ textView: UITextView) {
        willSendText()
    }
}
// MARK: - EmojiKeyboardDelegate
extension ZYInputBar: EmojiKeyboardDelegate {
    func emojikeyboard(_ emojikeyboard: EmojiKeyboard, didCheckItem emoji: Emoji) {
        textView.addEmoji(emoji)
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
            textView.attributedText = attributedText
            textView.selectedRange = .init(location: selectedRange.location, length: 0)
        } else {
            //删除表情
            attributedText.deleteCharacters(in: .init(location: selectedRange.location - 1, length:  1))
            textView.attributedText = attributedText
            textView.selectedRange = .init(location: selectedRange.location - 1, length: 0)
        }
    }

    func emojikeyboardDidSelectSend(_ emojikeyboard: EmojiKeyboard) {
        resignFirstResponder()
        type = .system
        willSendText()
    }
}

extension NSAttributedString {
    func asImage(height: CGFloat) -> UIImage? {
        // 过滤空""
        if string.isEmpty { return nil }
        let label = UILabel()
        label.attributedText = self
        label.sizeToFit()
        return label.asImage()
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
