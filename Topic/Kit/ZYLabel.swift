//
//  AttributedLabel.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

class ZYLabel: UILabel {
    private lazy var textStorage : NSTextStorage = NSTextStorage() // NSMutableAttributeString的子类
    private lazy var layoutManager : NSLayoutManager = NSLayoutManager() // 布局管理者
    private lazy var textContainer : NSTextContainer = NSTextContainer() // 容器,需要设置容器的大小

    var lineSpacing: CGFloat = 0 {
        didSet {
            prepareText()
        }
    }

    // MARK: - 重写系统属性
    override var text: String? {
        didSet{
           prepareText()
        }
    }

    override var attributedText: NSAttributedString? {
        didSet{
            prepareText()
        }
    }

    override var font: UIFont!{
        didSet{
            prepareText()
        }
    }

    override var textColor: UIColor!{
        didSet{
            
        }
    }

    override var numberOfLines: Int {
        didSet {
            self.textContainer.maximumNumberOfLines = numberOfLines
            textContainer.lineBreakMode = .byTruncatingTail
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
            prepareText()
        }
    }

    var display = Display()

    var dict: [String: Item] = [:]

    override var intrinsicContentSize: CGSize {
        return sizeThatFits(super.intrinsicContentSize)
    }

    /// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html
    public func proposedSizeWithConstrainedSize(constrainedSize: CGSize) -> CGSize {
        textContainer.size = constrainedSize
        var proposedSize = layoutManager.usedRect(for: textContainer).size
        proposedSize.width = ceil(proposedSize.width)
        proposedSize.height = ceil(proposedSize.height)
        return proposedSize
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var constrainedSize = size
        constrainedSize.height = CGFloat.greatestFiniteMagnitude
        return self.proposedSizeWithConstrainedSize(constrainedSize: constrainedSize)
    }

    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)

        perpareTextSystem()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        perpareTextSystem()
    }

    // MARK:- 布局子控件
    override open func layoutSubviews() {
        super.layoutSubviews()

//         设置容器的大小为Label的尺寸
        textContainer.size = frame.size
    }

    // MARK:- 重写drawTextInRect方法
    override open func drawText(in rect: CGRect) {
        // 2.绘制字形
        // 需要绘制的范围
        let range = NSRange(location: 0, length: textStorage.length)
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint.zero)
    }

    // MARK: 点击文本
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }

        // 获取点击了第几个字符
        let index = layoutManager.glyphIndex(for: location, in: textContainer)

        // 判断index是否在 range里
        for range in urlRanges ?? [] {
            if NSLocationInRange(index, range) {
                let str = (textStorage.string as NSString).substring(with: range)
//                delegate?.labelDidSelectedLink(text: str)
                if let item = dict[str] {
                    print(str, item)
                } else {
                    print(str)
                }
                return
            }
        }

        for range in topicRanges ?? [] {
            if NSLocationInRange(index, range) {
                let str = (textStorage.string as NSString).substring(with: range)
                if let item = dict[str] {
                    print(str, item)
                } else {
                    print(str)
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

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        prepareText()
    }

    func prepareText() {
        var attString: NSAttributedString
        if let attributedText = attributedText {
            attString = attributedText
        } else if let text = text {
            attString = NSAttributedString(string: text)
        } else {
            attString = NSAttributedString(string: "")
        }

        display.font = font
        let (resultText, dict) = display.displayValue(attString.string)
        self.dict = dict

        attString = display.replaceImage(resultText)

        let attrm = addLineBreak(attString)
        attrm.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: attrm.length))
        textStorage.setAttributedString(attrm)

        setupTextAttributes()
    }

    func addLineBreak(_ att: NSAttributedString) -> NSMutableAttributedString {
        let attM = NSMutableAttributedString(attributedString: att)

        if attM.length == 0 {
            return attM
        }

        var range = NSRange(location: 0, length: 0)

        var attributes = attM.attributes(at: 0, effectiveRange: &range)
        var paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSMutableParagraphStyle

        if paragraphStyle != nil {
//            paragraphStyle?.lineBreakMode = numberOfLines == 0 ? .byWordWrapping : .byTruncatingTail
            paragraphStyle?.lineSpacing = lineSpacing
        } else {
            paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle?.lineBreakMode = numberOfLines == 0 ? .byWordWrapping : .byTruncatingTail
            paragraphStyle?.lineSpacing = lineSpacing
            attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
            attM.setAttributes(attributes, range: range)
        }
        return attM
    }

    /// 设置 用户 话题 高亮状态
    func setupTextAttributes() {
        dict.forEach { (key, value) in
            let range = textStorage.string.range(of: key)
            textStorage.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: range)
        }
        setNeedsDisplay()
    }
}

// MARK: - 正则
private extension ZYLabel {
    var urlRanges: [NSRange]? {
        let pattern = "@[-_a-zA-Z0-9\\u4E00-\\u9FA5]+"
        return findRanges(pattern)
    }

    var topicRanges: [NSRange]? {
        let pattern = "#.*?#"
        return findRanges(pattern)
    }

    func findRanges(_ pattern: String) -> [NSRange]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        let results = regex.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        return results.map { $0.range }
    }
}


extension String {
    func range(of sub: String) -> NSRange {
        return (self as NSString).range(of: sub)
    }
}
