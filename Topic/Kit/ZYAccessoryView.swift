//
//  ZYAccessoryView.swift
//  Topic
//
//  Created by youzy01 on 2019/11/12.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit
protocol NavigationAccessory {
    /// 表情
    var emojiClosure: ((KeyboardType) -> ())? { get set }
    /// #
    var topicClosure: (() -> ())? { get set }
    /// @
    var userClosure: (() -> ())? { get set }
}

@IBDesignable
class ZYAccessoryView: UIView, NibLoadable, NavigationAccessory {
    @IBOutlet weak var toolBar: UIToolbar!

    var emojiClosure: ((KeyboardType) -> ())?
    var topicClosure: (() -> ())?
    var userClosure: (() -> ())?

    var keyboardType: KeyboardType = .system

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromNib()
    }

    @IBAction func changeAction() {
        keyboardType = keyboardType.toggle
        emojiClosure?(keyboardType)
    }
}
