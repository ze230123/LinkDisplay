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
        let item1 = TextLink(type: "#", name: "话题", id: "12345").json
        let item2 = TextLink(type: "@", name: "优志愿", id: "1").json
        let item3 = TextLink(type: "@", name: "用户1", id: "2").json
        let item4 = TextLink(type: "@", name: "用户2", id: "3").json
        let item5 = TextLink(type: "@", name: "用户3", id: "4").json
        let item6 = TextLink(type: "@", name: "用户4", id: "5").json

        return "\(item2) \(item2) 发half\(item3) 打开了\(item4)甲方诶返回r可\(item5) \(item1) 转发z抽奖 \(item6) 抽奖[标准微笑]抽奖[调皮吐舌微笑]抽奖"
    }

    @IBOutlet weak var countLabel: CountingLabel!
    @IBOutlet weak var label: ZYLabel!
    @IBOutlet weak var attlabel: TTTAttributedLabel!

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var inputBar: ZYInputBar!
    @IBOutlet weak var bottom: NSLayoutConstraint!

    var manager: KeyboardManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = KeyboardManager(view: view, bottom: bottom)

        label.delegate = self
        label.numberOfLines = 0
        label.layer.borderWidth = 0.5
        label.zy_text = text
        view.addSubview(label)

        inputBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.addObserver()
        inputBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        manager?.removeObserver()
        inputBar.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    @IBAction func addAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            inputBar.addLink(TextLink(type: "@", name: "优志愿", id: "1"))
        default:
            inputBar.addLink(TextLink(type: "#", name: "话题", id: "12345"))
        }
    }

    @IBAction func startAction() {
        countLabel.count(from: 0, to: 1000, with: 5)
    }
}

extension ViewController: ZYLabelDelegate {
    func zylabel(_ label: ZYLabel, didSelectAtUserText text: String, with item: TextLink) {
        print("@", text, item)
    }

    func zylabel(_ label: ZYLabel, didSelectTopicText text: String, with item: TextLink) {
        print("#", text, item)
    }
}

extension ViewController: ZYInputBarDelegate {
    func inputBarDidSelectAtUser(_ inputBar: ZYInputBar) {
        let vc = PresentViewController()
        vc.title = "关注用户"
        presentNavVc(vc)
    }

    func inputBarDidSelectTopic(_ inputBar: ZYInputBar) {
        let vc = PresentViewController()
        vc.title = "话题"
        presentNavVc(vc)
    }

    func inputBar(_ inputView: ZYInputBar, didSelectSendOf text: String) {
        label.zy_text = text
    }
}

extension ViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!) {
        if let json = components as? [String: Any], let item = TextLink(JSON: json) {
            print(item)
        }
    }
}

extension UIViewController {
    func present(_ vc: UIViewController, animated: Bool = true) {
        present(vc, animated: true, completion: nil)
    }

    func presentNavVc(_ vc: UIViewController, animated: Bool = true) {
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: animated)
    }
}
