//
//  ViewController.swift
//  Topic
//
//  Created by youzy01 on 2019/11/4.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ViewController: UIViewController {
    let textString = "{\"type\":\"#\",\"name\":\"话题\",\"id\":\"12345\"} 转发z抽奖 {\"type\":\"@\",\"name\":\"优志愿\",\"id\":\"54321\"}"

    var text: String {
        let item1 = Item(type: "#", name: "话题", id: "12345").json
        let item2 = Item(type: "@", name: "优志愿", id: "1").json
        let item3 = Item(type: "@", name: "用户1", id: "2").json
        let item4 = Item(type: "@", name: "用户2", id: "3").json
        let item5 = Item(type: "@", name: "用户3", id: "4").json
        let item6 = Item(type: "@", name: "用户4", id: "5").json
        return "\(item2) 发half\(item3) 打开了\(item4)甲方诶返回r可\(item5) \(item1) 转发z抽奖 \(item6) 抽奖[标准微笑]抽奖[调皮吐舌微笑]抽奖"
    }

    @IBOutlet weak var countLabel: CountingLabel!
    @IBOutlet weak var label: ZYLabel!
    @IBOutlet weak var attlabel: TTTAttributedLabel!

    @IBOutlet weak var inputBar: ZYInputView!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        label.lineSpacing = 5
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.gray
        label.numberOfLines = 2
        label.layer.borderWidth = 0.5
        label.zy_text = text
        view.addSubview(label)

        attlabel.delegate = self
        attlabel.layer.borderWidth = 0.5
        attlabel.lineSpacing = 5
        let display = Display()
        let (result, dict) = display.displayValue(text)
        attlabel.text = result
        attlabel.numberOfLines = 2
        for (key, item) in dict {
            let range = NSString(string: result).range(of: key)
            attlabel.addLink(toTransitInformation: item.toJSON(), with: range)
        }

        inputBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        inputBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    @IBAction func addAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            inputBar.addUser(Item(type: "@", name: "优志愿", id: "1"))
        default:
            break
        }
    }

    @IBAction func startAction() {
        countLabel.count(from: 0, to: 1000, with: 5)
    }
}

extension ViewController: ZYInputViewDelegate {
    func inputView(_ inputView: ZYInputView, didSelectSendOf text: String) {
        label.zy_text = text
    }
}

extension ViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        if let json = components as? [String: Any], let item = Item(JSON: json) {
            print(item)
        }
    }
}

extension ViewController {
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

        var newFrame = inputBar.frame
        newFrame.origin.y -= keyboardFrame.height

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
