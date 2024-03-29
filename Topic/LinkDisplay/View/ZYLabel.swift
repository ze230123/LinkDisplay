//
//  AttributedLabel.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

protocol ZYLabelDelegate: class {
    func zylabel(_ label: ZYLabel, didSelectAtUserText text: String, with item: TextLink)
    func zylabel(_ label: ZYLabel, didSelectTopicText text: String, with item: TextLink)
}

class ZYLabel: UILabel {
    var linkColor: UIColor = #colorLiteral(red: 0.3137254902, green: 0.4901960784, blue: 0.6862745098, alpha: 1)
    /// 赋值使用此属性，text/attributedText 不要使用
    var zy_text: String = "" {
        didSet {
            prepareText()
        }
    }

    /// 字符串转换工具
    var display = Display()
    /// @、话题 存储字典
    var dict: [String: TextLink] = [:]
    /// @、# range 集合
    var ranges = Set<NSRange>()

    weak var delegate: ZYLabelDelegate?

    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        perpareTextSystem()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        perpareTextSystem()
    }

    @objc func tapAction(gesture: UITapGestureRecognizer) {
        guard let text = self.attributedText?.string else { return }
        ranges.forEach { (range) in
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                // 获取点击的字符串 并找到对应模型
                let key = text.substring(range: range)
                let value = dict[key] ?? TextLink()
                switch value.linkType {
                case .atUser:
                    delegate?.zylabel(self, didSelectAtUserText: key, with: value)
                case .topic:
                    delegate?.zylabel(self, didSelectTopicText: key, with: value)
                default: break
                }
                return
            }
        }
    }
}

// MARK: - 准备文本
private extension ZYLabel {
    func perpareTextSystem() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(gesture:)))
        addGestureRecognizer(tap)
    }

    func prepareText() {
        display.font = font
        // 转换字符串、获取显示文字对应的字典、获取显示文字的range集合
        let (resultText, dict, ranges) = display.displayValue(zy_text)
        self.dict = dict
        self.ranges = ranges
        // 转换表情
        let attString = display.replaceImage(resultText)
        // 设置整体富文本属性
        let textRange = NSRange(location: 0, length: attString.length)
        attString.addAttribute(NSAttributedString.Key.font, value: font!, range: textRange)
        attString.addAttribute(.foregroundColor, value: textColor!, range: textRange)

        ranges.forEach { (item) in
            attString.addAttributes([NSAttributedString.Key.foregroundColor: linkColor], range: item)
        }
        attributedText = attString
    }
}

extension String {
    func range(of sub: String) -> NSRange {
        return (self as NSString).range(of: sub)
    }

    func substring(range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
}

private extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
            locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
