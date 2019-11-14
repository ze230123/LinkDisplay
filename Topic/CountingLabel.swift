//
//  CountingLabel.swift
//  Topic
//
//  Created by youzy01 on 2019/11/5.
//  Copyright © 2019 youzy. All rights reserved.
//

import UIKit
import SnapKit

protocol NibLoadable: class {
    func loadViewFromNib() -> UIView
    func initViewFromNib(enabled: Bool)
}

extension NibLoadable where Self: UIView {

    func loadViewFromNib() -> UIView {
        let className = type(of: self)
        let bundle = Bundle(for: className)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        let nib = UINib(nibName: name!, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }

    func initViewFromNib(enabled: Bool = true) {
        let contentView = loadViewFromNib()
        contentView.isUserInteractionEnabled = enabled
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
}
@IBDesignable
class CountingLabel: UIView, NibLoadable {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!

    @IBOutlet weak var stackView: UIStackView!

    /// 动画时间
    private let duration: TimeInterval = 1
    /// 开始数字
    private var fromValue: Double = 0
    /// 结束数字
    private var toValue: Double = 0
    /// 计时器
    private var timer: CADisplayLink?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViewFromNib()
    }

//    [myLabel countFrom:50 to:100 withDuration:5.0f];

    func count(from: Double, to: Double, with duration: TimeInterval) {
        label1.isHidden = to < 1000

        self.fromValue = from
        self.toValue = to

        stop()

        if duration == 0.0 {
            setTextValue(value: to)
            return
        }

        progress = 0.0
        totalTime = duration
        lastUpdateTime = Date.timeIntervalSinceReferenceDate

        start()
    }

    /// 开始计时
    private func start() {
        timer = CADisplayLink(target: self, selector: #selector(updateValue(timer:)))
        timer?.add(to: .main, forMode: RunLoop.Mode.default)
        timer?.add(to: .main, forMode: RunLoop.Mode.tracking)
    }

    /// 停止计时
    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private var progress: TimeInterval = 0

    private var lastUpdateTime: TimeInterval = 0
    private var totalTime: TimeInterval = 0

    private var currentValue: Double {
        if progress >= totalTime { return toValue }
        return fromValue + Double(progress / totalTime) * (toValue - fromValue)
    }


    @objc fileprivate func updateValue(timer: CADisplayLink) {
        let now = Date.timeIntervalSinceReferenceDate
        progress += now - lastUpdateTime
        lastUpdateTime = now

        if progress >= totalTime {
            stop()
            progress = totalTime
        }

        setTextValue(value: currentValue)

    }

    private func setTextValue(value: Double) {
        label1.text = "\(Int(value).thousandsValue)"
        label2.text = "\(Int(value).hundredsValue)"
        label3.text = "\(Int(value).tenValue)"
        label4.text = "\(Int(value).singleValue)"
    }

    override var intrinsicContentSize: CGSize {
        let width = stackView.arrangedSubviews.filter{ !$0.isHidden }.map { $0.intrinsicContentSize.width }.reduce(0, +)
        return CGSize(width: width, height: label4.intrinsicContentSize.height)
    }
}

extension Int {
    /// 千位的值
    var thousandsValue: Int {
        return self / 1000
    }

    /// 百位的值
    var hundredsValue: Int {
        return self / 100 % 10
    }

    /// 十位的值
    var tenValue: Int {
        return self / 10 % 10
    }

    /// 个位的值
    var singleValue: Int {
        return self % 10
    }
}
