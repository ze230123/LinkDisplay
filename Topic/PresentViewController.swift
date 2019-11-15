//
//  PresentViewController.swift
//  Topic
//
//  Created by youzy01 on 2019/11/15.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit

class PresentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(leftAction))
        navigationItem.leftBarButtonItem = item

        view.backgroundColor = UIColor.blue
    }

    @objc func leftAction() {
        dismiss(animated: true, completion: nil)
    }
}
