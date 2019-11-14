//
//  AttributedLabel.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

class ZYLabel: UILabel {
    var zy_text: String = "" {
        didSet {
            prepareText()
        }
    }

    var display = Display()

    var dict: [String: Item] = [:]

    var lineSpacing: CGFloat = 0

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
        dict.forEach { (key, value) in
            let range = text.range(of: key)
            if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                print(key, value)
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
        let (resultText, dict) = display.displayValue(zy_text)
        self.dict = dict

        let attString = display.replaceImage(resultText)

        let textRange = NSRange(location: 0, length: attString.length)
        attString.addAttribute(NSAttributedString.Key.font, value: font!, range: textRange)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing
        paragraph.lineBreakMode = lineBreakMode

        attString.addAttribute(.paragraphStyle, value: paragraph, range: textRange)

        dict.forEach { (key, value) in
            let range = attString.string.range(of: key)
            attString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: range)
        }
        attributedText = attString
    }
}

extension String {
    func range(of sub: String) -> NSRange {
        return (self as NSString).range(of: sub)
    }
}

extension UITapGestureRecognizer {

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
