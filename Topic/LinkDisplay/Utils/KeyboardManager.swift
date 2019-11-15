//
//  KeyboardManager.swift
//  Topic
//
//  Created by youzy01 on 2019/11/15.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

/// 管理键盘弹出、收回时 底部输入框的位置
class KeyboardManager {
    weak var view: UIView!
    weak var bottom: NSLayoutConstraint!

    init(view: UIView, bottom: NSLayoutConstraint) {
        self.view = view
        self.bottom = bottom
    }

    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardManager.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
        }

        let keyboardFrame = endFrameValue.cgRectValue

        var inset: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            inset = view.safeAreaInsets
        }
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.bottom.constant = keyboardFrame.height - inset.bottom
            // 没有下面这句代码，不会有动画
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
        }
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.bottom.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
