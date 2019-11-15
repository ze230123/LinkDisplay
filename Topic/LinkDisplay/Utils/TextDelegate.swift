//
//  TextDelegate.swift
//  Topic
//
//  Created by youzy01 on 2019/11/15.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

protocol ZYTextViewDelegate: class {
    func textViewDidSelectSendItem(_ textView: UITextView)
}

class TextDelegate: NSObject, UITextViewDelegate {
    weak var delegate: ZYTextViewDelegate?

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            delegate?.textViewDidSelectSendItem(textView)
            return false
        }
        return true
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }

    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false
    }
}
